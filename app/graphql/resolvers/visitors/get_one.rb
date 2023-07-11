# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetOne < Resolvers::Base
      type 'Types::Visitors::Visitor', null: true

      argument :visitor_id, GraphQL::Types::ID, required: true

      def resolve_with_timings(visitor_id:)
        query = <<-SQL
          visitors.*,
          BOOL_OR(recordings.viewed) viewed,
          MIN(recordings.connected_at) first_viewed_at,
          MAX(recordings.disconnected_at) last_activity_at,
          MIN(recordings.locale) locale,
          SUM(recordings.pages_count) page_views_count,
          AVG(recordings.activity_duration) average_recording_duration,
          COUNT(recordings.*) total_recording_count,
          COUNT(CASE WHEN recordings.viewed THEN 1 ELSE 0 END) new_recording_count,
          COUNT(pages.*) total_page_views,
          COUNT(DISTINCT(pages.url)) unique_page_views,
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

        visitor = Visitor
                  .left_outer_joins(recordings: :pages)
                  .select(query)
                  .where('visitors.site_id = ? AND visitors.id = ?', object.id, visitor_id)
                  .group(:id)
                  .first

        return unless visitor

        format_visitor(visitor)
      end

      private

      def format_visitor(visitor)
        hash = {
          id: visitor.id,
          site_id: visitor.site_id,
          visitor_id: visitor.visitor_id,
          viewed: visitor.viewed,
          recording_count: {
            total: visitor.total_recording_count,
            new: visitor.new_recording_count
          },
          first_viewed_at: visitor.first_viewed_at,
          last_activity_at: visitor.last_activity_at,
          language: Locale.get_language(visitor.locale),
          page_views_count: {
            total: visitor.total_page_views,
            unique: visitor.unique_page_views
          },
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
  end
end
