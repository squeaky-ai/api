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
        count(recordings) recording_count,
        MIN(recordings.connected_at) first_viewed_at,
        MAX(recordings.disconnected_at) last_activity_at,
        MAX(recordings.locale) locale,
        MAX(recordings.viewport_x) viewport_x,
        MAX(recordings.viewport_y) viewport_y,
        MAX(recordings.useragent) useragent,
        SUM(array_length(recordings.page_views, 1)) page_view_count
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
