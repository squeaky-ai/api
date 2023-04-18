# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Site do
  let(:email) { 'email@site.com' }
  let(:domain) { 'site-domain.com' }
  let(:site_name) { SecureRandom.uuid }
  let(:api_endpoint) { 'https://test-api.com' }
  let(:response) { double(:response, body: response_body, code: 200) }

  let(:auth) do
    {
      'type' => 'bearer',
      'authorization_code' => 'authorization_code',
      'refresh_token' => 'refresh_token',
      'expiration_date' => 1671227759134
    }
  end

  let(:response_body) do
    {
      'site_domain' => domain,
      'site_name' => site_name,
      'account_name' => email
    }.to_json
  end

  let(:instance) { described_class.new(site_name:, api_endpoint:, auth:) }

  before do
    ENV['DUDA_USERNAME'] = 'username'
    ENV['DUDA_PASSWORD'] = 'password'
    ENV['DUDA_APP_UUID'] = SecureRandom.uuid

    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#name' do
    subject { instance.name }

    it 'returns the name' do
      expect(subject).to eq('site-domain')
    end
  end

  describe '#domain' do
    subject { instance.domain }

    it 'returns the domain' do
      expect(subject).to eq("https://#{domain}")
    end
  end

  describe '#uuid' do
    subject { instance.uuid }

    it 'returns the uuid' do
      expect(subject).to eq(site_name)
    end
  end

  describe '#account_name' do
    subject { instance.account_name }

    it 'returns the email' do
      expect(subject).to eq(email)
    end
  end
end
