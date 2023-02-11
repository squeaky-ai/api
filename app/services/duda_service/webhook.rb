# frozen_string_literal: true

module DudaService
  class Webhook
    def initialize(event_type:, data:, resource_data:)
      @event_type = event_type
      @data = data
      @resource_data = resource_data
    end

    def process!
      case event_type
      when 'DOMAIN_UPDATED'
        process_domain_updated
      else
        Rails.logger.info("Ignoring Duda webhook with event_type: #{event_type}")
      end
    end

    private

    attr_reader :event_type, :data, :resource_data

    def process_domain_updated
      site = ::Site.find_by!(uuid: resource_data['site_name'])
      site.update(url: domain)
    end

    def domain
      "https://#{data['domain'].presence || data['sub_domain'].presence}"
    end
  end
end
