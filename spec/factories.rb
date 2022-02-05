# frozen_string_literal: true

require 'securerandom'

FactoryBot.define do
  factory :user do
    first_name { 'Jim' }
    last_name  { 'Morrison' }
    email { "#{SecureRandom.base36}@email.com" }
    password { 'sdfsfsdfsdfsdf' }
    confirmed_at { Time.now }
  end

  factory :team do
    role { Team::OWNER }
    status { Team::ACCEPTED }

    user { association :user }
    site { association :site }
  end

  factory :site do
    name { 'Morrison Hotel' }
    url { "https://#{SecureRandom.base36}.com" }
    plan { Site::ESSENTIALS }
    uuid { SecureRandom.uuid }
    verified_at { Time.now }

    transient do
      team_count { 1 }
      owner { create(:user) }
    end

    factory :site_with_team do
      after(:create) do |site, evaluator|
        create_list(:team, evaluator.team_count, site: site, user: evaluator.owner)
      end      
    end
  end

  factory :recording do
    session_id { SecureRandom.base36 }
    locale { 'en-GB' }
    useragent { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:96.0) Gecko/20100101 Firefox/96.0' }
    browser { 'Firefox' }
    device_type { 'Desktop' }
    viewport_x { 1920 }
    viewport_y { 1080 }
    device_x { 1920 }
    device_y { 1080 }
    status { Recording::ACTIVE }
    connected_at { Time.now.to_i * 1000 }
    disconnected_at { (Time.now.to_i + 1000) * 1000 }

    transient do
      page_urls { ['/'] }
    end

    after(:create) do |recording, evaluator|
      evaluator.page_urls.each { |url| create(:page, url: url, recording: recording) }
    end

    site { association :site }
    visitor { association :visitor }
  end

  factory :page do
    url { '/' }
    entered_at { 1631629334592 }
    exited_at { 1631629343582 }

    recording { association :recording }
  end

  factory :visitor do
    visitor_id { SecureRandom.base36 }
    starred { false }
    external_attributes { {} }
  end

  factory :tag do
    name { 'The Soft Parade' }

    site { association :site }
  end

  factory :note do
    body { 'Strange Days' }
    timestamp { 12312 }

    user { association :user }
  end

  factory :nps do
    score { 5 }
    comment { nil }

    recording { association :recording }
  end

  factory :sentiment do
    score { 5 }
    comment { nil }

    recording { association :recording }
  end

  factory :billing do
    customer_id { SecureRandom.base36 }
    status { 'new' }

    site { association :site }
    user { association :user }
  end
end
