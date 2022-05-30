# frozen_string_literal: true

namespace :click_house do
  task prepare: :environment do
    @environments = Rails.env.development? ? %w[development test] : [Rails.env]
  end

  task drop: :prepare do
    @environments.each do |env|
      config = ClickHouse.config.clone.assign(Rails.application.config_for('click_house', env:))
      connection = ClickHouse::Connection.new(config)
      connection.drop_database(config.database, if_exists: true)
    end
  end

  task create: :prepare do
    @environments.each do |env|
      config = ClickHouse.config.clone.assign(Rails.application.config_for('click_house', env:))
      connection = ClickHouse::Connection.new(config)
      connection.create_database(config.database, if_not_exists: true)
    end
  end

  task :backfill, [:site_id] => :environment do |_t, args|
    Site.find(args[:site_id]).recordings.find_each do |recording|
      Rails.logger.info("Backfilling recording #{recording.id}")

      ClickHouse::Event.insert do |buffer|
        recording.events.find_each do |event|
          buffer << {
            uuid: SecureRandom.uuid,
            site_id: recording.site_id,
            recording_id: recording.id,
            type: event.event_type,
            source: event.data['source'],
            data: event.data.to_json,
            timestamp: event.timestamp
          }
        end
      end
    end
  end
end
