# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'aws-sdk-rails', '~> 3'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'click_house'
gem 'devise'
gem 'devise_invitable'
gem 'graphql'
gem 'graphql_playground-rails'
gem 'httparty'
gem 'kaminari'
gem 'nokogiri'
gem 'pg', '~> 1.4.4'
gem 'puma'
gem 'rack-cors'
gem 'rails'
gem 'redis'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'stripe'
gem 'useragent'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 6.0.1'
  gem 'rubocop'
  gem 'rubocop-rails', require: false
end

group :development do
  gem 'listen', '~> 3.7'
end

group :test do
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
