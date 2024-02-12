# frozen_string_literal: true

module DudaService
  class Webhook
    def initialize(event_type:, data:, resource_data:)
      @event_type = event_type
      @data = data
      @resource_data = resource_data
    end

    def process!
      unless site
        Rails.logger.warn "Site #{resource_data['site_name']} not found"
        return
      end

      case event_type
      when 'DOMAIN_UPDATED'
        process_domain_updated
      when 'PUBLISH'
        process_duda_published
      else
        Rails.logger.info("Ignoring Duda webhook with event_type: #{event_type}")
      end
    end

    private

    attr_reader :event_type, :data, :resource_data

    def site
      @site ||= ::Site.find_by(uuid: resource_data['site_name'])
    end

    def process_domain_updated
      site.update(url: domain, name:)
    end

    def process_duda_published
      site.provider_auth.publish_history << Time.current.iso8601
      site.provider_auth.save
    end

    def domain
      "https://#{data['domain'].presence || data['sub_domain'].presence}"
    end

    def name
      url_parts = URI(domain).host.split('.')
      url_parts.pop
      url_parts.join('.').sub('www.', '')
    end
  end
end
