# frozen_string_literal: true

task visitors_cleanup: :environment do
  sql = <<-SQL
    SELECT DISTINCT(visitor_id) visitor_id FROM recordings;
  SQL

  results = Sql.execute(sql).map { |x| x['visitor_id'] }

  client = Aws::S3::Client.new
  client.put_object(body: results.to_json, bucket: 'misc.squeaky.ai', key: 'visitor_export.json')

  nil
end
