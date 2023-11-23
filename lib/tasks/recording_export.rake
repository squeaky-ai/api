# frozen_string_literal: true

task :recording_export, [:site_id] => :environment do |_task, args|
  raise ArgumentError, "Missing site_id, usage: bundle exec rake recording_export'[site_id]'" unless args[:site_id]

  csv_string = CSV.generate(headers: true) do |csv|
    csv << %w[email_address connected_at disconnected_at total_duration activity_duration country_code]

    Recording.where(site_id: args[:site_id]).find_each do |recording|
      csv << [
        recording.visitor.external_attributes['email'],
        recording.connected_at.iso8601,
        recording.disconnected_at.iso8601,
        recording.duration,
        recording.activity_duration,
        recording.country_code
      ]
    end
  end

  client = Aws::S3::Client.new

  client.put_object(
    body: csv_string,
    bucket: 'misc.squeaky.ai',
    key: "#{args[:site_id]}/#{Time.current.to_i}.csv"
  )
end
