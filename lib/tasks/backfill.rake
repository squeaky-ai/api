# frozen_string_literal: true

namespace :backfill do
  task devices: :environment do
    Recording.all.each do |r|
      r.browser = r.user_agent.browser
      r.device_type = r.user_agent.mobile? ? 'Mobile' : 'Computer'
      r.save
    end
  end
end
