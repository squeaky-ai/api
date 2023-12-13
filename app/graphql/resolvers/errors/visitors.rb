# frozen_string_literal: true

module Resolvers
  module Errors
    class Visitors < Resolvers::Base
      type 'Types::Visitors::Visitors', null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'

      def resolve(page:, size:, sort:)
        query = <<-SQL.squish
          visitors.*,
          BOOL_OR(recordings.viewed) viewed,
          MIN(recordings.connected_at) first_viewed_at,
          MAX(recordings.disconnected_at) last_activity_at,
          MIN(recordings.locale) locale,
          SUM(recordings.pages_count) page_views_count,
          AVG(recordings.activity_duration) average_recording_duration,
          COUNT(DISTINCT recordings.id) total_recording_count,
          COUNT(DISTINCT CASE WHEN recordings.viewed THEN NULL ELSE recordings.id END) new_recording_count,
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
          .where('recordings.id IN (?)', recording_ids)
          .order(order(sort))
          .group('visitors.id')

        visitors = visitors.page(page).per(size)

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

      def recording_ids
        sql = <<-SQL.squish
          SELECT DISTINCT recording_id
          FROM error_events
          WHERE
            site_id = :site_id AND
            message = :message AND
            toDate(timestamp / 1000, :timezone)::date BETWEEN :from_date AND :to_date
        SQL

        variables = {
          site_id: object.site.id,
          message: Base64.decode64(object.error_id),
          timezone: object.range.timezone,
          from_date: object.range.from,
          to_date: object.range.to
        }

        Sql::ClickHouse.select_all(sql, variables).pluck('recording_id')
      end

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
    end
  end
end
