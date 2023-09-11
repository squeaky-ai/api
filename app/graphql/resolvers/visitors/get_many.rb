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
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(page:, size:, search:, sort:, filters:, from_date:, to_date:) # rubocop:disable Metrics/ParameterLists
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        query = <<-SQL
          visitors.*,
          BOOL_OR(recordings.viewed) viewed,
          MIN(recordings.connected_at) first_viewed_at,
          MAX(recordings.disconnected_at) last_activity_at,
          MIN(recordings.locale) locale,
          SUM(recordings.pages_count) page_views_count,
          AVG(recordings.activity_duration) average_recording_duration,
          COUNT(DISTINCT recordings.id) total_recording_count,
          COUNT(CASE WHEN recordings.viewed THEN 1 ELSE 0 END) new_recording_count,
          ARRAY_AGG(DISTINCT(recordings.country_code)) country_codes,
          JSON_AGG(JSON_BUILD_OBJECT(
            'browser',     recordings.browser,
            'useragent',   recordings.useragent,
            'viewport_x',  recordings.viewport_x,
            'viewport_y',  recordings.viewport_y,
            'device_x',    recordings.device_x,
            'device_y',    recordings.device_y,
            'device_type', recordings.device_type
          )) devices
        SQL

        visitors = Visitor
                   .left_outer_joins(:recordings)
                   .select(query)
                   .where(
                     'visitors.site_id = ? AND visitors.updated_at::date BETWEEN ? AND ?',
                     object.id,
                     range.from,
                     range.to
                   )
                   .order(order(sort))

        # Apply all the filters
        visitors = filter(visitors, filters)

        # Apply the search
        visitors = filter_search(visitors, search)

        # Paginate the results
        visitors = visitors.page(page).per(size).group(:id)

        {
          items: format_visitors(visitors),
          pagination: {
            page_size: size,
            total: visitors.total_count,
            sort:
          }
        }
      end

      private

      def format_visitors(visitors)
        visitors.map do |visitor|
          hash = {
            id: visitor.id,
            visitor_id: visitor.visitor_id,
            viewed: visitor.viewed,
            recording_count: {
              total: visitor.total_recording_count,
              new: visitor.new_recording_count
            },
            first_viewed_at: visitor.first_viewed_at,
            last_activity_at: visitor.last_activity_at,
            language: Locale.get_language(visitor.locale),
            page_views_count: { total: 0, unique: 0 }, # This is expensive for many visitors, don't try it
            starred: visitor.starred,
            linked_data: visitor.linked_data,
            devices: visitor.devices.map { |device| Devices.format(device) },
            countries: Countries.to_code_and_name(visitor.country_codes),
            source: visitor.source,
            average_recording_duration: visitor.average_recording_duration,
            created_at: visitor.created_at
          }

          Struct.new(*hash.keys).new(*hash.values)
        end
      end

      def order(sort)
        sorts = {
          'first_viewed_at__asc' => 'MIN(recordings.connected_at) ASC',
          'first_viewed_at__desc' => 'MIN(recordings.connected_at) DESC',
          'last_activity_at__asc' => 'MAX(recordings.disconnected_at) ASC',
          'last_activity_at__desc' => 'MAX(recordings.disconnected_at) DESC',
          'recordings__asc' => 'recordings_count ASC',
          'recordings__desc' => 'recordings_count DESC',
          'average_recording_duration__asc' => 'AVG(recordings.activity_duration) ASC',
          'average_recording_duration__desc' => 'AVG(recordings.activity_duration) DESC'
        }
        sorts[sort]
      end

      def filter(visitors, filters)
        if filters
          visitors = filter_by_status(visitors, filters)
          visitors = filter_by_recordings(visitors, filters)
          visitors = filter_by_language(visitors, filters)
          visitors = filter_by_browsers(visitors, filters)
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

      # Adds a filter that lets users show only visitors
      # who have recordings with given browsers
      def filter_by_browsers(visitors, filters)
        return visitors unless filters.browsers.any?

        visitors.where('recordings.browser IN (?)', filters.browsers)
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
