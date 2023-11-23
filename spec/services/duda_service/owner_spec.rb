# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Owner do
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

  let(:first_name) { 'Bob' }
  let(:last_name) { 'Dylan' }
  let(:email) { 'bob@dylan.com' }

  let(:response_body) do
    {
      'first_name' => first_name,
      'last_name' => last_name,
      'email' => email
    }.to_json
  end

  let(:instance) { described_class.new(site_name:, api_endpoint:, auth:) }

  before do
    ENV['DUDA_USERNAME'] = 'username'
    ENV['DUDA_PASSWORD'] = 'password'

    allow(HTTParty).to receive(:get).and_return(response)
  end

  describe '#first_name' do
    subject { instance.first_name }

    it 'returns the first_name' do
      expect(subject).to eq(first_name)
    end
  end

  describe '#last_name' do
    subject { instance.last_name }

    it 'returns the last_name' do
      expect(subject).to eq(last_name)
    end
  end

  describe '#email' do
    subject { instance.email }

    it 'returns the email' do
      expect(subject).to eq(email)
    end
  end
end
