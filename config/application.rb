# frozen_string_literal: true

require_relative 'boot'

require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'action_cable/engine'
require 'action_text/engine'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Squeaky
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    config.middleware.use Rack::Deflater

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = 'Central Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join('extras')

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.eager_load_paths << Rails.root.join('lib')

    config.action_cable.mount_path = '/api/in'
    config.action_cable.disable_request_forgery_protection = true

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: 'session', expire_after: 3.months, domain: :all

    config.plans = config_for(:plans)
    config.countries = config_for(:countries)
    config.languages = config_for(:languages)
    config.timezones = config_for(:timezones)

    config.active_job.queue_adapter = :sidekiq
  end
end
