# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Webhook do
  describe '#process!' do
    context 'when the event_type is DOMAIN_UPDATED' do
      let(:provider_uuid) { SecureRandom.uuid }
      let(:event_type) { 'DOMAIN_UPDATED' }

      let(:site) { create(:site, provider: 'duda', uuid: provider_uuid) }

      let(:data) do
        {
          'domain' => nil,
          'sub_domain' => 'mysite.com'
        }
      end

      let(:resource_data) do
        {
          'site_name' => provider_uuid
        }
      end

      subject { described_class.new(event_type:, data:, resource_data:).process! }

      it 'updates the sites domain' do
        expect { subject }.to change { site.reload.url }.to("https://#{data['sub_domain']}")
      end
    end
  end
end
