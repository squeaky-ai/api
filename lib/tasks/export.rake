# frozen_string_literal: true

namespace :export do
  task clicks: :environment do
    sql = <<-SQL.squish
      SELECT *
      FROM clicks
      WHERE site_id = 82;
    SQL

    results = Sql::ClickHouse.select_all(sql)

    client = Aws::S3::Client.new

    client.put_object(
      body: results.to_json,
      bucket: 'squeaky_site_export',
      key: 'clicks'
    )
  end

  task recordings: :environment do
    sql = <<-SQL.squish
      SELECT *
      FROM recordings
      WHERE site_id = 82;
    SQL

    results = Sql::ClickHouse.select_all(sql)

    client = Aws::S3::Client.new

    client.put_object(
      body: results.to_json,
      bucket: 'squeaky_site_export',
      key: 'recordings'
    )
  end

  task page_views: :environment do
    sql = <<-SQL.squish
      SELECT *
      FROM page_events
      WHERE site_id = 82;
    SQL

    results = Sql::ClickHouse.select_all(sql)

    client = Aws::S3::Client.new

    client.put_object(
      body: results.to_json,
      bucket: 'squeaky_site_export',
      key: 'page_views'
    )
  end
end
