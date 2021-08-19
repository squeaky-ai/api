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

      sql = <<-SQL
        visitor_id,
        count(*) recording_count,
        MIN(connected_at) first_viewed_at,
        MAX(connected_at) last_activity_at,
        MAX(locale) locale,
        ROUND(AVG(viewport_x), 0) viewport_x,
        ROUND(AVG(viewport_y), 0) viewport_y,
        MAX(useragent) useragent,
        SUM(array_length(page_views, 1)) page_view_count
      SQL

      visitor = Recording
                .select(sql)
                .where('site_id = ? AND visitor_id = ?', site_id, visitor_id)
                .group(:visitor_id)

      # .first on it's own will use ActiveRecord, causing
      # some fuss over recording.id not being grouped, which
      # we're actively ignoring here
      visitor.to_a.first
    end
  end
end
