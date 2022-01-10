# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetMany < Resolvers::Base
      type Types::Visitors::Visitors, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'
      argument :filters, Types::Visitors::Filters, required: false, default_value: nil

      def resolve(page:, size:, sort:, filters:)
        visitors = Site
                   .find(object.id)
                   .visitors
                   .includes(:recordings)
                   .where('recordings.status = ?', Recording::ACTIVE)
                   .order(order(sort))

        # Apply all the filters
        visitors = filter(visitors, filters)

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
        end

        visitors
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
        return visitors unless filters.first_visited[:range_type]

        return filter_by_between_first_visited(visitors, filters) if filters.first_visited[:range_type] == 'Between'

        return filter_by_before_first_viewed(visitors, filters) if filters.first_visited[:from_type] == 'Before'

        return filter_by_after_first_viewed(visitors, filters) if filters.first_visited[:from_type] == 'After'

        visitors
      end

      # Allow filtering of visitors where one of their recordings
      # first appeared between two dates
      def filter_by_between_first_visited(visitors, filters)
        from_date = format_date(filters.first_visited[:between_from_date])
        to_date = format_date(filters.first_visited[:between_to_date])

        visitors.having('to_timestamp(MIN(recordings.connected_at) / 1000)::date BETWEEN ? AND ?', from_date, to_date)
      end

      # Allow filtering of visitors where one of their recordings
      # first appeared before a date
      def filter_by_before_first_viewed(visitors, filters)
        from_date = format_date(filters.first_visited[:from_date])

        visitors.having('to_timestamp(MIN(recordings.connected_at) / 1000)::date < ?', from_date)
      end

      # Allow filtering of visitors where one of their recordings
      # first appeared after a dates
      def filter_by_after_first_viewed(visitors, filters)
        from_date = format_date(filters.first_visited[:from_date])

        visitors.having('to_timestamp(MIN(recordings.connected_at) / 1000)::date > ?', from_date)
      end

      # Adds a filter that lets users show only visitors
      # who last interacted a website within a given time
      # frame
      def filter_by_last_activity(visitors, filters)
        return visitors unless filters.last_activity[:range_type]

        return filter_by_between_last_activity(visitors, filters) if filters.last_activity[:range_type] == 'Between'

        return filter_by_before_last_activity(visitors, filters) if filters.last_activity[:from_type] == 'Before'

        return filter_by_after_last_activity(visitors, filters) if filters.last_activity[:from_type] == 'After'

        visitors
      end

      # Allow filtering of visitors where one of their recordings
      # last had activity between two dates
      def filter_by_between_last_activity(visitors, filters)
        from_date = format_date(filters.last_activity[:between_from_date])
        to_date = format_date(filters.last_activity[:between_to_date])

        visitors.having('to_timestamp(MAX(recordings.disconnected_at) / 1000)::date BETWEEN ? AND ?', from_date, to_date)
      end

      # Allow filtering of visitors where one of their recordings
      # last had activity before a date
      def filter_by_before_last_activity(visitors, filters)
        from_date = format_date(filters.last_activity[:from_date])

        visitors.having('to_timestamp(MAX(recordings.disconnected_at) / 1000)::date < ?', from_date)
      end

      # Allow filtering of visitors where one of their recordings
      # last had activity after a date
      def filter_by_after_last_activity(visitors, filters)
        from_date = format_date(filters.last_activity[:from_date])

        visitors.having('to_timestamp(MAX(recordings.disconnected_at) / 1000)::date > ?', from_date)
      end

      # Adds a filter that lets users show only visitors
      # who have recordings in givin languages
      def filter_by_language(visitors, filters)
        return visitors unless filters.languages.any?

        locales = filters.languages.map { |l| Locale.get_locale(l).downcase }

        visitors.where('LOWER(recordings.locale) IN (?)', locales)
      end

      def format_date(string)
        string.split('/').reverse.join('-')
      end
    end
  end
end
