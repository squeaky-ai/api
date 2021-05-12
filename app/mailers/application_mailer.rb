# frozen_string_literal: true

# Base class for all mailers
class ApplicationMailer < ActionMailer::Base
  default from: 'Squeaky.ai <hello@squeaky.ai>'
  layout 'mailer'

  def initialize
    super

    @web_url = web_url
  end

  private

  def web_url
    # Because this is using the api-only flag the routing
    # doesn't seem to include any of the helpers (like root_url)
    # so we build it from the config
    config = Rails.application.config.action_mailer.default_url_options
    url = "#{config[:protocol]}://#{config[:host]}"
    url += ":#{config[:port]}" if config[:port]
    url
  end
end
