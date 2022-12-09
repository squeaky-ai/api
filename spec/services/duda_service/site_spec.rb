# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Site do
  let(:site_name) { SecureRandom.uuid }
  let(:api_endpoint) { 'https://test-api.com' }
  let(:response) { double(:response, body: response_body) }

  let(:response_body) do
    {
      'site_default_domain' => 'https://site-domain.com',
      'site_name' => site_name
    }.to_json
  end

  let(:instance) { described_class.new(site_name:, api_endpoint:) }

  before do
    ENV['DUDA_USERNAME'] = 'username'
    ENV['DUDA_PASSWORD'] = 'password'

    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#name' do
    subject { instance.name }

    it 'returns the name' do
      expect(subject).to eq('TODO')
    end
  end

  describe '#domain' do
    subject { instance.domain }

    it 'returns the domain' do
      expect(subject).to eq('https://site-domain.com')
    end
  end

  describe '#uuid' do
    subject { instance.uuid }

    it 'returns the uuid' do
      expect(subject).to eq(site_name)
    end
  end
end
