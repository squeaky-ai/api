# frozen_string_literal: true

module Resolvers
  module Recordings
    class GetMany < Resolvers::Base
      type Types::Recordings::Recordings, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'
      argument :filters, Types::Recordings::Filters, required: false, default_value: nil
      argument :from_date, String, required: true
      argument :to_date, String, required: true

      def resolve(page:, size:, sort:, filters:, from_date:, to_date:)
        recordings = Site
                     .find(object.id)
                     .recordings
                     .includes(:nps, :sentiment)
                     .joins(:pages, :visitor)
                     .preload(:pages, :visitor)
                     .where(
                       'recordings.status = ? AND
                       to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?',
                       Recording::ACTIVE, from_date, to_date
                     )
                     .order(order(sort))

        # Apply all the filters
        recordings = filter(recordings, filters)

        # Paginate the results
        recordings = recordings.page(page).per(size).group(:id)

        {
          items: recordings,
          pagination: {
            page_size: size,
            total: recordings.total_count,
            sort: sort
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'connected_at__asc' => 'connected_at ASC',
          'connected_at__desc' => 'connected_at DESC',
          'duration__asc' => Arel.sql('(disconnected_at - connected_at) ASC'),
          'duration__desc' => Arel.sql('(disconnected_at - connected_at) DESC'),
          'page_count__asc' => 'pages_count ASC',
          'page_count__desc' => 'pages_count DESC'
        }
        sorts[sort]
      end

      def filter(recordings, filters)
        if filters
          filter_options = %w[
            status
            duration
            start_url
            exit_url
            visited_pages
            unvisited_pages
            device
            browser
            viewport
            language
            bookmarked
            referrers
            starred
            tags
          ]

          filter_options.each do |option|
            method = "filter_by_#{option}"
            recordings = send(method, recordings, filters) if respond_to?(method, true)
          end
        end

        recordings
      end

      # Adds a filter that lets users show only recordings
      # that have been viewed or not
      def filter_by_status(recordings, filters)
        return recordings unless filters.status

        recordings.where('recordings.viewed = ?', filters.status == 'Viewed')
      end

      # Add a filter that lets users show only recordings
      # that have a certain duration
      def filter_by_duration(recordings, filters)
        return recordings unless filters.duration[:range_type]

        return filter_by_between_durations(recordings, filters) if filters.duration[:range_type] == 'Between'

        return filter_by_greater_than_duration(recordings, filters) if filters.duration[:from_type] == 'GreaterThan'

        return filter_by_less_than_duration(recordings, filters) if filters.duration[:from_type] == 'LessThan'

        recordings
      end

      # Allow filtering of recordings where it's duration
      # was between two amounts
      def filter_by_between_durations(recordings, filters)
        from_duration = filters.duration[:between_from_duration]
        to_duration = filters.duration[:between_to_duration]

        recordings.where('recordings.disconnected_at - recordings.connected_at BETWEEN ? AND ?', from_duration, to_duration)
      end

      # Allow filtering of recordings where it's duration
      # was greater than an amount
      def filter_by_greater_than_duration(recordings, filters)
        from_duration = filters.duration[:from_duration]

        recordings.where('recordings.disconnected_at - recordings.connected_at > ?', from_duration)
      end

      # Allow filtering of recordings where it's duration
      # was less than an amount
      def filter_by_less_than_duration(recordings, filters)
        from_duration = filters.duration[:from_duration]

        recordings.where('recordings.disconnected_at - recordings.connected_at < ?', from_duration)
      end

      # Allow filtering of recordings that have a particular
      # start url
      def filter_by_start_url(recordings, filters)
        return recordings unless filters.start_url

        sql = <<-SQL
          ? IN (
            SELECT url
            FROM pages
            WHERE pages.recording_id = recordings.id
            ORDER BY pages.entered_at ASC
            LIMIT 1
          )
        SQL

        recordings.where(sql, filters.start_url)
      end

      # Allow filtering of recordings that have a particular
      # exit url
      def filter_by_exit_url(recordings, filters)
        return recordings unless filters.exit_url

        sql = <<-SQL
          ? IN (
            SELECT url
            FROM pages
            WHERE pages.recording_id = recordings.id
            ORDER BY pages.exited_at DESC
            LIMIT 1
          )
        SQL

        recordings.where(sql, filters.exit_url)
      end

      # Allow filtering of recordings that include certain
      # pages
      def filter_by_visited_pages(recordings, filters)
        return recordings unless filters.visited_pages.any?

        sql = <<-SQL
          ? IN (
            SELECT url
            FROM pages
            WHERE pages.recording_id = recordings.id
          )
        SQL

        filters.visited_pages.each { |page| recordings = recordings.where(sql, page) }
        recordings
      end

      # Allow filtering of recordings that exclude certain
      # pages
      def filter_by_unvisited_pages(recordings, filters)
        return recordings unless filters.unvisited_pages.any?

        sql = <<-SQL
          ? NOT IN (
            SELECT url
            FROM pages
            WHERE pages.recording_id = recordings.id
          )
        SQL

        filters.unvisited_pages.each { |page| recordings = recordings.where(sql, page) }
        recordings
      end

      # Add a filter that lets users show only recordings
      # that were on certain devices
      def filter_by_device(recordings, filters)
        return recordings unless filters.devices.any?

        recordings.where('recordings.device_type IN (?)', filters.devices)
      end

      # Add a filter that lets users show only recordings
      # that used certain browsers
      def filter_by_browser(recordings, filters)
        return recordings unless filters.browsers.any?

        recordings.where('recordings.browser IN (?)', filters.browsers)
      end

      # Allow filtering of recordings that have certain
      # dimensions
      def filter_by_viewport(recordings, filters)
        viewport = filters.viewport

        return recordings unless viewport.values.any?

        recordings = recordings.where('recordings.viewport_x > ?', viewport[:min_width]) if viewport[:min_width]
        recordings = recordings.where('recordings.viewport_x < ?', viewport[:max_width]) if viewport[:max_width]
        recordings = recordings.where('recordings.viewport_y > ?', viewport[:min_height]) if viewport[:min_height]
        recordings = recordings.where('recordings.viewport_y < ?', viewport[:max_height]) if viewport[:max_height]

        recordings
      end

      # Add a filter that lets users show only recordings
      # that have certain languages
      def filter_by_language(recordings, filters)
        return recordings unless filters.languages.any?

        locales = filters.languages.map { |l| Locale.get_locale(l).downcase }

        recordings.where('LOWER(recordings.locale) IN (?)', locales)
      end

      # Add a filter that lets users show only recordings
      # that have been bookmarked
      def filter_by_bookmarked(recordings, filters)
        return recordings if filters.bookmarked.nil?

        recordings.where('recordings.bookmarked = ?', filters.bookmarked)
      end

      # Adds a filter that lets users show only recordings
      # that were from one of the referrers
      def filter_by_referrers(recordings, filters)
        return recordings unless filters.referrers.any?

        has_none = filters.referrers.any? { |r| r == 'none' }

        if has_none
          recordings.where('recordings.referrer IS NULL OR recordings.referrer IN (?)', filters.referrers)
        else
          recordings.where('recordings.referrer IN (?)', filters.referrers)
        end
      end

      # Adds a filter that lets users show only recordings
      # where the visitor has been starred
      def filter_by_starred(recordings, filters)
        return recordings if filters.starred.nil?

        recordings.where('visitors.starred = ? ', filters.starred)
      end

      # Adds a filter that lets users show only recordings
      # that contain certain tags
      def filter_by_tags(recordings, filters)
        return recordings unless filters.tags.any?

        recordings
          .joins(:tags)
          .where('tags.id IN (?)', filters.tags)
      end
    end
  end
end
