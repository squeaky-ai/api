# frozen_string_literal: true

module Types
  # The ratio of desktop to mobile
  class AnalyticsDevicesExtension < AnalyticsQuery
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT useragent
        FROM recordings
        WHERE site_id = ? AND created_at::date BETWEEN ? AND ?;
      SQL

      result = execute_sql(sql, [site_id, from_date, to_date])
      map_results(result)
    end

    private

    def map_results(result)
      groups = result.partition { |r| UserAgent.parse(r.first).mobile? }

      [
        {
          type: 'mobile',
          count: groups[0].size
        },
        {
          type: 'desktop',
          count: groups[1].size
        }
      ]
    end
  end
end
