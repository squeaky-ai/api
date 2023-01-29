# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Squeaky.ai <hello@squeaky.ai>'
  layout 'mailer'

  after_action :fire_squeaky_event

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

  def fire_squeaky_event
    EventTrackingJob.perform_later(
      name: "#{self.class}##{action_name}",
      data: {
        to: headers['to'].to_s,
        sent_at: Time.now.iso8601
      }
    )
  end
end
