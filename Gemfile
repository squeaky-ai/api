# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3', '~> 1.110'
gem 'bootsnap', require: false
gem 'click_house'
gem 'devise'
gem 'devise_invitable'
gem 'graphql'
gem 'graphql_playground-rails'
gem 'kaminari'
gem 'pg', '~> 1.3.5'
gem 'puma', '~> 5.6'
gem 'rack-cors'
gem 'rails', '~> 7.0.2'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'stripe'
gem 'useragent'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 5.1'
end

group :development do
  gem 'listen', '~> 3.7'
end

group :test do
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
