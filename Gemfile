# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'aws-sdk-rails', '~> 3'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'graphql'
gem 'graphql_playground-rails'
gem 'jwt'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 6.1.3', '>= 6.1.3.1'
gem 'redis', '~> 4.0'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'faker'
  gem 'rspec-rails', '~> 5.0.0'
end

group :development do
  gem 'listen', '~> 3.3'
  gem 'spring'
end

group :test do
  gem 'simplecov', require: false
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
