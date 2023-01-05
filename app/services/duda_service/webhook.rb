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
      auth = ::ProviderAuth.find_by!(provider: 'duda', provider_uuid: resource_data['site_name'])
      auth.site.update(url:)
    end

    def url
      data['domain'].presence || data['subdomain'].presence
    end
  end
end
