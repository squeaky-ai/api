# frozen_string_literal: true

module Resolvers
  module Admin
    class AdTracking < Resolvers::Base
      type [Types::Admin::AdTracking, { null: false }], null: false

      argument :utm_content_ids, [String, { null: false }], required: true, default_value: []

      def resolve_with_timings(utm_content_ids:)
        ad_tracking = fetch_ad_tracking(utm_content_ids)

        format_response(ad_tracking)
      end

      private

      def format_response(ad_tracking)
        ad_tracking.map do |a|
          {
            visitor_id: a['visitor_id'],
            user_id: a['user_id'],
            user_name: "#{a['user_first_name']} #{a['user_last_name']}",
            user_created_at: a['user_created_at'],
            site_id: a['site_id'],
            site_name: a['site_name'],
            site_created_at: a['site_created_at'],
            site_verified_at: a['site_verified_at'],
            site_plan_name: Plans.name_for(plan_id: a['site_plan_id']),
            utm_content: a['utm_content']
          }
        end
      end

      def fetch_ad_tracking(utm_content_ids)
        sql = <<-SQL
          SELECT
            visitors.visitor_id visitor_id,
            users.id user_id,
            users.first_name user_first_name,
            users.last_name user_last_name,
            users.created_at user_created_at,
            sites.id site_id,
            sites.name site_name,
            sites.created_at site_created_at,
            sites.verified_at site_verified_at,
            plans.plan_id site_plan_id,
            recordings.utm_content utm_content
          FROM
            recordings
          INNER JOIN
            visitors ON visitors.id = recordings.visitor_id
          LEFT OUTER JOIN
            users ON users.id::text = visitors.external_attributes->>'id'::text
          LEFT OUTER JOIN
            teams ON teams.user_id = users.id
          LEFT OUTER JOIN
            sites ON sites.id = teams.site_id
          LEFT OUTER JOIN
            plans ON plans.site_id = sites.id
          WHERE
            recordings.site_id = ? AND
            #{content_query(utm_content_ids)}
        SQL

        variables = [Rails.application.config.squeaky_site_id]
        variables << utm_content_ids unless utm_content_ids.empty?

        Sql.execute(sql, variables)
      end

      def content_query(utm_content_ids)
        return 'recordings.utm_content IS NOT null' if utm_content_ids.empty?

        'recordings.utm_content IN (?)'
      end
    end
  end
end
