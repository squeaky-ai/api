# frozen_string_literal: true

module Types
  # Get a single visitor by their visitor_id
  class VisitorExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:visitor_id, GraphQL::Types::ID, required: true, description: 'The id of the visitor')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      visitor_id = arguments[:visitor_id]

      select_sql = <<-SQL
        visitors.id id,
        visitors.visitor_id visitor_id,
        visitors.starred starred,
        visitors.external_attributes external_attributes,
        COUNT(CASE recordings.deleted WHEN TRUE THEN NULL ELSE TRUE END) recording_count,
        COUNT(CASE recordings.viewed WHEN TRUE THEN 1 ELSE NULL END) viewed_recording_count,
        MIN(recordings.connected_at) first_viewed_at,
        MAX(recordings.disconnected_at) last_activity_at,
        MAX(recordings.locale) locale,
        array_agg(recordings.viewport_x || '__' || recordings.viewport_y || '__' || recordings.useragent) recording_data,
        SUM(array_length(recordings.page_views, 1)) page_view_count,
        array_agg(array_length(array_unique(recordings.page_views), 1)) unique_page_view_count
      SQL

      visitor = Visitor
                .joins(:recordings)
                .select(select_sql)
                .where('recordings.site_id = ? AND visitors.id = ?', site_id, visitor_id)
                .group(%i[id visitor_id])
                .limit(1)

      # .first on it's own will use ActiveRecord, causing
      # some fuss over recording.id not being grouped, which
      # we're actively ignoring here
      visitor.to_a.first
    end
  end
end
