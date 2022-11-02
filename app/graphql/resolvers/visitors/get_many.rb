# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetMany < Resolvers::Base
      type 'Types::Visitors::Visitors', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :search, String, required: false, default_value: nil
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'
      argument :filters, Types::Visitors::Filters, required: false, default_value: nil

      def resolve_with_timings(page:, size:, search:, sort:, filters:)
        visitors = object
                   .visitors
                   .includes(:recordings)
                   .order(order(sort))

        # Apply all the filters
        visitors = filter(visitors, filters)

        # Apply the search
        visitors = filter_search(visitors, search)

        # Paginate the results
        visitors = visitors.page(page).per(size).group(:id)

        {
          items: visitors,
          pagination: {
            page_size: size,
            total: visitors.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'first_viewed_at__asc' => 'MIN(connected_at) ASC',
          'first_viewed_at__desc' => 'MIN(connected_at) DESC',
          'last_activity_at__asc' => 'MAX(disconnected_at) ASC',
          'last_activity_at__desc' => 'MAX(disconnected_at) DESC',
          'recordings__asc' => 'recordings_count ASC',
          'recordings__desc' => 'recordings_count DESC'
        }
        sorts[sort]
      end

      def filter(visitors, filters)
        if filters
          visitors = filter_by_status(visitors, filters)
          visitors = filter_by_recordings(visitors, filters)
          visitors = filter_by_language(visitors, filters)
          visitors = filter_by_first_visited(visitors, filters)
          visitors = filter_by_last_activity(visitors, filters)
          visitors = filter_by_visited_pages(visitors, filters)
          visitors = filter_by_unvisited_pages(visitors, filters)
          visitors = filter_by_referrers(visitors, filters)
          visitors = filter_by_starred(visitors, filters)
        end

        visitors
      end

      def filter_search(visitors, search)
        return visitors if search.blank?

        query = "%#{search}%"

        visitors.where('visitors.external_attributes::text ILIKE :query OR visitors.visitor_id ILIKE :query', query:)
      end

      # Adds a filter that lets users show only visitors
      # who have had at least one of their recordings viewed
      def filter_by_status(visitors, filters)
        return visitors unless filters.status

        visitors.having('EVERY(recordings.viewed = ?)', filters.status == 'Viewed')
      end

      # Adds a filter that lets users show only visitors
      # who have more than or less than a given amount of
      # recordings
      def filter_by_recordings(visitors, filters)
        return visitors unless filters.recordings[:count]

        range_type = filters.recordings[:range_type] == 'GreaterThan' ? '>' : '<'

        visitors.having("recordings_count #{range_type} ?", filters.recordings[:count])
      end

      # Adds a filter that lets users show only visitors
      # who first visited a website within a given time
      # frame
      def filter_by_first_visited(visitors, filters)
        return visitors unless filters.first_visited

        visitors.having(
          'to_timestamp(MIN(recordings.connected_at) / 1000)::date BETWEEN ? AND ?',
          filters.first_visited[:from_date],
          filters.first_visited[:to_date]
        )
      end

      # Adds a filter that lets users show only visitors
      # who last interacted a website within a given time
      # frame
      def filter_by_last_activity(visitors, filters)
        return visitors unless filters.last_activity

        visitors.having(
          'to_timestamp(MAX(recordings.disconnected_at) / 1000)::date BETWEEN ? AND ?',
          filters.last_activity[:from_date],
          filters.last_activity[:to_date]
        )
      end

      # Adds a filter that lets users show only visitors
      # who have recordings in givin languages
      def filter_by_language(visitors, filters)
        return visitors unless filters.languages.any?

        locales = filters.languages.map { |l| Locale.get_locale(l).downcase }

        visitors.where('LOWER(recordings.locale) IN (?)', locales)
      end

      # Allow filtering of visitors that include certain
      # pages
      def filter_by_visited_pages(visitors, filters)
        return visitors unless filters.visited_pages.any?

        sql = <<-SQL
          ? IN (
            SELECT pages.url
            FROM pages
            INNER JOIN recordings ON pages.recording_id = recordings.id
            WHERE recordings.visitor_id = visitors.id
          )
        SQL

        filters.visited_pages.each { |page| visitors = visitors.where(sql, page) }
        visitors
      end

      # Allow filtering of visitors that exclude certain
      # pages
      def filter_by_unvisited_pages(visitors, filters)
        return visitors unless filters.unvisited_pages.any?

        sql = <<-SQL
          ? NOT IN (
            SELECT pages.url
            FROM pages
            INNER JOIN recordings ON pages.recording_id = recordings.id
            WHERE recordings.visitor_id = visitors.id
          )
        SQL

        filters.unvisited_pages.each { |page| visitors = visitors.where(sql, page) }
        visitors
      end

      # Adds a filter that lets users show only visitors
      # that were from one of the referrers
      def filter_by_referrers(visitors, filters)
        return visitors unless filters.referrers.any?

        has_none = filters.referrers.any? { |r| r == 'none' }

        if has_none
          visitors.where('recordings.referrer IS NULL OR recordings.referrer IN (?)', filters.referrers)
        else
          visitors.where('recordings.referrer IN (?)', filters.referrers)
        end
      end

      # Adds a filter that lets users show only visitors
      # that are starred
      def filter_by_starred(visitors, filters)
        return visitors if filters.starred.nil?

        visitors.where('visitors.starred = ?', filters.starred)
      end
    end
  end
end
