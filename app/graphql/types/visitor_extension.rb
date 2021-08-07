# frozen_string_literal: true

module Types
  # Get a single visitor by their viewer_id
  class VisitorExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:viewer_id, GraphQL::Types::ID, required: true, description: 'The id of the viewer')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      viewer_id = arguments[:viewer_id]

      sql = <<-SQL
        viewer_id,
        count(*) recording_count,
        MIN(connected_at) first_viewed_at,
        MAX(connected_at) last_activity_at,
        MAX(locale) locale,
        ROUND(AVG(viewport_x), 0) viewport_x,
        ROUND(AVG(viewport_y), 0) viewport_y,
        MAX(useragent) useragent,
        SUM(array_length(page_views, 1)) page_view_count
      SQL

      viewer = Recording
               .select(sql)
               .where('site_id = ? AND viewer_id = ?', site_id, viewer_id)
               .group(:viewer_id)

      # .first on it's own will use ActiveRecord, causing
      # some fuss over recording.id not being grouped, which
      # we're actively ignoring here
      viewer.to_a.first
    end
  end
end
