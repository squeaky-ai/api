# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Install do
  describe '#install_all!' do
    let(:account_owner_uuid) { SecureRandom.uuid }
    let(:site_name) { SecureRandom.uuid }
    let(:account_name) { 'account@site.com' }
    let(:api_endpoint) { 'https://api-endpoint.com' }
    let(:plan_uuid) { '304e8866-7b29-4027-bcb3-3828204d9cfd' }
    let(:dashboard_domain) { 'https://dashboard_domain.com' }

    let(:auth) do
      {
        'type' => 'bearer',
        'authorization_code' => 'authorization_code',
        'refresh_token' => 'refresh_token',
        'expiration_date' => 1671227759134
      }
    end

    let(:uuid) { site_name }
    let(:domain) { 'my-domain.com' }

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

    let(:branding_response_body) do
      {
        'dashboard_domain' => dashboard_domain
      }.to_json
    end

    let(:owner_response_body) do
      {
        'first_name' => first_name,
        'last_name' => last_name,
        'email' => email
      }.to_json
    end

    let(:site_response) { double(:site_response, body: site_response_body, code: 200) }
    let(:branding_response) { double(:branding_response, body: branding_response_body, code: 200) }
    let(:owner_response) { double(:owner_response, body: owner_response_body, code: 200) }
    let(:script_response) { double(:script_response, body: '', code: 200) }

    before do
      ENV['DUDA_USERNAME'] = 'username'
      ENV['DUDA_PASSWORD'] = 'password'
      ENV['DUDA_APP_UUID'] = SecureRandom.uuid

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}", anything)
        .and_return(site_response)

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/branding", anything)
        .and_return(branding_response)

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/account/details", anything)
        .and_return(owner_response)

      allow(HTTParty).to receive(:post)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
        .and_return(script_response)
    end

    subject do
      described_class.new(
        account_owner_uuid:,
        site_name:,
        api_endpoint:,
        auth:,
        plan_uuid:
      ).install_all!
    end

    it 'creates a site with the params' do
      subject
      site = Site.find_by(uuid: site_name)
      expect(site.uuid).to eq(uuid)
      expect(site.name).to eq('my-domain')
      expect(site.url).to eq("https://#{domain}")
      expect(site.verified_at).not_to be_nil
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
      expect(auth.deep_link_url).to eq("#{dashboard_domain}/home/site/#{site_name}?appstore&appId=#{Duda::Client.app_uuid}")
    end

    it 'injects the script' do
      subject

      expect(HTTParty).to have_received(:post)
        .with("#{api_endpoint}/api/integrationhub/application/site/#{site_name}/sitewidehtml", anything)
    end

    it 'starts the free trial' do
      subject

      site = Site.find_by(uuid: site_name)
      plan = Plan.find_by(site_id: site['id'])

      expect(plan.max_monthly_recordings).to eq(1500)
      expect(plan.features_enabled).to eq(Types::Plans::Feature.values.keys)
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

    context 'when the site is on a paid plan' do
      let(:plan_uuid) { '5d6b2b10-9c27-49e5-b3d7-a78b176f80b4' }

      it 'puts them on the correct plan' do
        subject
        site = Site.last
        expect(site.plan.plan_id).to eq('b5be7346-b896-4e4f-9598-e206efca98a6')
      end

      it 'does not trigger the free trial job' do
        subject
        site = Site.last
        expect(site.plan.max_monthly_recordings).to eq(25_000)
      end
    end
  end
end
