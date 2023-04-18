# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProviderAuth, type: :model do
  describe '#provider_app_uuid' do
    context 'when the provider is duda' do
      let(:app_uuid) { SecureRandom.uuid }
      let(:instance) { create(:provider_auth, provider: 'duda') }

      subject { instance.provider_app_uuid }

      before do
        ENV['DUDA_APP_UUID'] = app_uuid
      end

      it 'returns the uuid' do
        expect(subject).to eq(app_uuid)
      end
    end
  end

  describe '#refresh_token!' do
    context 'when the provider is duda' do
      let(:app_uuid) { SecureRandom.uuid }
      let(:instance) { create(:provider_auth, provider: 'duda') }

      let(:expiration_date) { Time.now.to_i }
      let(:authorization_code) { SecureRandom.uuid }

      let(:response) { double(:response, body: response_body, code: 200) }

      let(:response_body) do
        {
          'expiration_date' => expiration_date,
          'authorization_code' => authorization_code
        }.to_json
      end

      subject { instance.refresh_token! }

      before do
        ENV['DUDA_USERNAME'] = 'username'
        ENV['DUDA_PASSWORD'] = 'password'
        ENV['DUDA_APP_UUID'] = SecureRandom.uuid

        allow(HTTParty).to receive(:post).and_return(response)
      end

      it 'updates the access token and expiry date' do
        expect { subject }.to change { instance.reload.access_token }.to(authorization_code)
      end
    end
  end
end
