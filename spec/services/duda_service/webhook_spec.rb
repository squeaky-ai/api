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

    context 'when the event_type is PUBLISH' do
      let(:provider_uuid) { SecureRandom.uuid }
      let(:event_type) { 'PUBLISH' }

      let(:now) { Time.current.iso8601 }
      let(:site) { create(:site, provider: 'duda', uuid: provider_uuid) }

      let(:data) { {} }

      let(:resource_data) do
        {
          'site_name' => provider_uuid
        }
      end

      before do
        create(:provider_auth, site:)
        allow(Time.current).to receive(:iso8601).and_return(now)
      end

      subject { described_class.new(event_type:, data:, resource_data:).process! }

      it 'updates the publish history' do
        expect { subject }.to change { site.provider_auth.reload.publish_history }.from([]).to([now])
      end

      context 'when there are existing publish dates' do
        before do
          site.provider_auth.update(publish_history: [now, now, now])
        end

        it 'adds the new history' do
          expect { subject }.to change { site.provider_auth.reload.publish_history.size }.from(3).to(4)
        end
      end
    end
  end
end
