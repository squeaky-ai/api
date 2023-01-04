# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Install do
  describe '#install_all!' do
    let(:account_owner_uuid) { SecureRandom.uuid }
    let(:site_name) { SecureRandom.uuid }
    let(:account_name) { 'account@site.com' }
    let(:api_endpoint) { 'https://api-endpoint.com' }

    let(:auth) do
      {
        'type' => 'bearer',
        'authorization_code' => 'authorization_code',
        'refresh_token' => 'refresh_token',
        'expiration_date' => 1671227759134
      }
    end

    let(:uuid) { site_name }
    let(:domain) { 'https://my-domain.com' }

    let(:first_name) { 'Bob' }
    let(:last_name) { 'Dylan' }
    let(:email) { 'bob@dylan.com' }

    let(:site_response_body) do
      {
        'site_default_domain' => domain,
        'site_name' => site_name,
        'account_name' => account_name,
        'site_business_info' => {}
      }.to_json
    end

    let(:user_response_body) do
      {
        'first_name' => first_name,
        'last_name' => last_name,
        'email' => email
      }.to_json
    end

    let(:site_response) { double(:site_response, body: site_response_body) }
    let(:user_response) { double(:user_response, body: user_response_body) }
    let(:script_response) { double(:script_response, body: '') }

    before do
      ENV['DUDA_USERNAME'] = 'username'
      ENV['DUDA_PASSWORD'] = 'password'

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}", anything)
        .and_return(site_response)

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/accounts/#{account_name}", anything)
        .and_return(user_response)

      allow(HTTParty).to receive(:post)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
        .and_return(script_response)
    end

    subject do
      described_class.new(
        account_owner_uuid:,
        site_name:,
        api_endpoint:,
        auth:
      ).install_all!
    end

    it 'creates a site with the params' do
      subject
      site = Site.find_by(uuid: site_name)
      expect(site.uuid).to eq(uuid)
      expect(site.name).to eq('Unkown')
      expect(site.url).to eq(domain)
    end

    it 'creates the owner and team' do
      subject

      site = Site.find_by(uuid: site_name)
      user = User.find_by(provider_uuid: account_owner_uuid)

      expect(user).not_to be_nil
      expect(user.email).to eq(email)
      expect(user.first_name).to eq(first_name)
      expect(user.last_name).to eq(last_name)
      expect(user.provider).to eq('duda')
      expect(user.owner_for?(site)).to eq(true)
    end

    it 'creates the auth' do
      subject

      auth = ProviderAuth.find_by(provider_uuid: site_name)

      expect(auth.provider).to eq('duda')
      expect(auth.auth_type).to eq('bearer')
      expect(auth.provider_uuid).to eq(site_name)
      expect(auth.access_token).to eq('authorization_code')
      expect(auth.refresh_token).to eq('refresh_token')
      expect(auth.expires_at).to eq(1671227759134)
    end

    it 'injects the script' do
      subject

      expect(HTTParty).to have_received(:post)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
    end

    context 'when the user exists already' do
      before do
        create(:user, first_name:, last_name:, email:)
      end

      it 'does not recreate the user' do
        expect { subject }.not_to change { User.all.count }
      end

      it 'does still create the team' do
        expect { subject }.to change { Team.all.count }.by(1)
      end

      it 'does still create the site' do
        expect { subject }.to change { Site.all.count }.by(1)
      end

      it 'does still inject the script' do
        subject
  
        expect(HTTParty).to have_received(:post)
          .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
      end
    end
  end
end
