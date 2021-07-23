# frozen_string_literal: true

module Types
  # Analytics data
  class AnalyticsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:id]

      {
        visitors: visitors(site_id),
        page_views: page_views(site_id),
        average_session_duration: average_session_duration(site_id),
        pages_per_session: pages_per_session(site_id)
      }
    end

    private

    def visitors(site_id)
      sql = "SELECT COUNT ( DISTINCT(viewer_id) ) FROM recordings WHERE site_id = #{site_id};"
      execute(sql).to_i
    end

    def page_views(site_id)
      sql = "SELECT SUM( array_length(page_views, 1) ) FROM recordings WHERE site_id = #{site_id};"
      execute(sql).to_i
    end

    def average_session_duration(site_id)
      sql = "SELECT AVG( (disconnected_at - connected_at) ) as DURATION FROM recordings WHERE site_id = #{site_id};"
      execute(sql).to_i
    end

    def pages_per_session(site_id)
      sql = "SELECT AVG( array_length(page_views, 1) ) FROM recordings WHERE site_id = #{site_id};"
      execute(sql).to_f
    end

    def execute(sql)
      ActiveRecord::Base.connection.execute(sql).values[0][0]
    end
  end
end
