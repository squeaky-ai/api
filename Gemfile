# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'aws-sdk-rails', '~> 3'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'devise'
gem 'devise_invitable', '~> 2.0.0'
gem 'graphql'
gem 'graphql_playground-rails'
gem 'kaminari'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.1'
gem 'redis'
gem 'scenic'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'stripe'
gem 'useragent'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'rspec-rails', '~> 5.0.0'
end

group :development do
  gem 'listen', '~> 3.3'
end

group :test do
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
