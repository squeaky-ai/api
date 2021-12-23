# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    first_name { 'Jim' }
    last_name  { 'Morisson' }
    email { "#{SecureRandom.base36}@email.com" }
    password { 'sdfsfsdfsdfsdf' }
    confirmed_at { Time.now }
  end
end
