# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Script do
  let(:site) { create(:site) }
  let(:site_name) { SecureRandom.uuid }
  let(:api_endpoint) { 'https://api-endpoint.com' }

  let(:auth) do
    {
      'type' => 'bearer',
      'authorization_code' => 'authorization_code',
      'refresh_token' => 'refresh_token',
      'expiration_date' => 1671227759134
    }
  end

  let(:response) { double(:response, body: '{}') }

  let(:instance) { described_class.new(site:, site_name:, api_endpoint:, auth:) }

  before do
    ENV['DUDA_USERNAME'] = 'username'
    ENV['DUDA_PASSWORD'] = 'password'

    allow(HTTParty).to receive(:post).and_return(response)
  end

  describe '#inject_script!' do
    subject { instance.inject_script! }

    it 'returns the response' do
      expect(subject).to eq({})
    end

    it 'makes the request to Duda' do
      subject

      expect(HTTParty).to have_received(:post)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
    end
  end
end
