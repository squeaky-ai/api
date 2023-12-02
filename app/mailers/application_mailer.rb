# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Squeaky.ai <hello@squeaky.ai>'
  layout 'mailer'

  after_action :fire_squeaky_event

  def initialize
    super

    @web_url = web_url
  end

  # Weird syntax isn't it
  helper_method def squeaky_web_url(path: '', skip_deeplink: false)
    # If it's not a site email or the site has
    # no provider then send them to Squeaky
    return "#{web_url}#{path}" if skip_deeplink
    return "#{web_url}#{path}" unless @site&.provider

    provider_deep_link_url
  end

  helper_method def squeaky_app_url(path: '', skip_deeplink: false)
    # If it's not a site email or the site has
    # no provider then send them to Squeaky
    return "#{app_url}#{path}" if skip_deeplink
    return "#{app_url}#{path}" unless @site&.provider

    provider_deep_link_url
  end

  private

  def web_url
    Rails.application.config.web_host
  end

  def app_url
    Rails.application.config.app_host
  end

  def provider_deep_link_url
    # If they have a provider then we should send
    # them to the deep link url
    provider = ProviderAuth.find_by(provider_uuid: @site.uuid)
    provider.deep_link_url
  end

  def fire_squeaky_event
    EventTrackingJob.perform_later(
      name: "#{self.class}##{action_name}",
      data: {
        to: headers['to'].to_s,
        sent_at: Time.current.iso8601
      }
    )
  end
end
