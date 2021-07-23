# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:date_string, String, required: true, description: 'The date to fetch data for')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      date_string = arguments[:date_string].split('/').join('-')

      {
        visitors: visitors(site_id, date_string),
        page_views: page_views(site_id, date_string),
        average_session_duration: average_session_duration(site_id, date_string),
        pages_per_session: pages_per_session(site_id, date_string),
        pages: pages(site_id, date_string)
      }
    end

    private

    def visitors(site_id, date_string)
      sql = <<-SQL
        SELECT COUNT ( DISTINCT(viewer_id) )
        FROM recordings
        WHERE site_id = ? AND created_at::date = ?;
      SQL
      execute(sql, [site_id, date_string])[0][0].to_i
    end

    def page_views(site_id, date_string)
      sql = <<-SQL
        SELECT SUM( array_length(page_views, 1) )
        FROM recordings
        WHERE site_id = ? AND created_at::date = ?;
      SQL
      execute(sql, [site_id, date_string])[0][0].to_i
    end

    def average_session_duration(site_id, date_string)
      sql = <<-SQL
        SELECT AVG( (disconnected_at - connected_at) ) as DURATION
        FROM recordings
        WHERE site_id = ? AND created_at::date = ?;
      SQL
      execute(sql, [site_id, date_string])[0][0].to_i
    end

    def pages_per_session(site_id, date_string)
      sql = <<-SQL
        SELECT AVG( array_length(page_views, 1) )
        FROM recordings
        WHERE site_id = ? AND created_at::date = ?;
      SQL
      execute(sql, [site_id, date_string])[0][0].to_f
    end

    def pages(site_id, date_string)
      sql = <<-SQL
        SELECT p.page_view, count(*) page_view_count
        FROM recordings r
        cross join lateral unnest(r.page_views) p(page_view)
        WHERE r.site_id = ? AND r.created_at::date = ?
        group by p.page_view
        order by page_view_count desc;
      SQL
      result = execute(sql, [site_id, date_string])
      result.map { |r| [[:path, r[0]], [:count, r[1]]].to_h }
    end

    def execute(query, variables)
      # TODO: Is this even right haha? It seems so jank for
      # something I would have thought would be clean in
      # Rails
      sql = ActiveRecord::Base.sanitize_sql_array([query, *variables])
      ActiveRecord::Base.connection.execute(sql).values
    end
  end
end
