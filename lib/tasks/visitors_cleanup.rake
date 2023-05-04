# frozen_string_literal: true

task visitors_cleanup: :environment do
  sql = <<-SQL
    SELECT
      visitors.id visitor_id,
      count(recordings.id) count
    FROM
      visitors
    LEFT JOIN
      recordings ON recordings.visitor_id = visitors.id
    GROUP BY
      visitors.id
    HAVING
      COUNT(recordings.id) = 0
  SQL

  body = Sql.execute(sql).to_json

  client = Aws::S3::Client.new

  client.put_object(body:, bucket: 'misc.squeaky.ai', key: 'visitors_count.json')
end
