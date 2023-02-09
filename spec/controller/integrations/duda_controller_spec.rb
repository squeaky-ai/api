# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::DudaController, type: :controller do
  describe 'POST /integrations/websitebuilder/install' do
    let(:account_owner_uuid) { SecureRandom.uuid }
    let(:installer_account_uuid) { SecureRandom.uuid }
    let(:site_name) { SecureRandom.uuid }
    let(:account_name) { 'account@site.com' }
    let(:api_endpoint) { 'https://api-endpoint.com' }
    let(:app_plan_uuid) { '304e8866-7b29-4027-bcb3-3828204d9cfd' }
    let(:dashboard_domain) { 'https://dashboard_domain.com' }

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

    let(:params) do
      {
        account_owner_uuid:, 
        installer_account_uuid:, 
        site_name:, 
        api_endpoint:,
        auth:,
        app_plan_uuid:
      }
    end

    let(:site_response_body) do
      {
        'site_default_domain' => 'https://my-domain.com',
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
      post :install, params:
    end

    it 'returns okay' do
      subject

      expect(response).to have_http_status(200)
      expect(json_body).to eq('status' => 'OK')
    end

    it 'creates the site' do
      expect { subject }.to change { Site.all.count }.by(1)
    end

    it 'creates the user' do
      expect { subject }.to change { User.all.count }.by(1)
    end

    it 'creates the team' do
      expect { subject }.to change { Team.all.count }.by(1)
    end
  end

  describe 'POST /integrations/websitebuilder/uninstall' do
    let!(:site) { create(:site) }

    let(:params) do
      {
        site_name: site.uuid
      }
    end

    subject do
      post :uninstall, params:
    end

    it 'returns okay' do
      subject

      expect(response).to have_http_status(200)
      expect(json_body).to eq('status' => 'OK')
    end

    it 'deletes the site' do
      expect { subject }.to change { Site.all.count }.by(-1)
    end
  end

  describe 'POST /integrations/websitebuilder/change_plan' do
    let(:provider_uuid) { SecureRandom.uuid }
    let!(:site) { create(:site, uuid: provider_uuid) }

    let(:params) do
      {
        site_name: site.uuid,
        app_plan_uuid: '5d6b2b10-9c27-49e5-b3d7-a78b176f80b4'
      }
    end

    subject do
      post :change_plan, params:
    end

    it 'updates the plan' do
      expect { subject }.to change { site.reload.plan.plan_id }
        .from('05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
        .to('b5be7346-b896-4e4f-9598-e206efca98a6')
    end

    it 'returns okay' do
      subject

      expect(response).to have_http_status(200)
      expect(json_body).to eq('status' => 'OK')
    end
  end
  
  describe 'GET /integrations/websitebuilder/sso' do
    let!(:user) { create(:user, provider: 'duda', provider_uuid: SecureRandom.uuid) }
    let!(:site) { create(:site_with_team, owner: user) }

    let(:site_name) { 'squeaky' }
    let(:sdk_url) { 'https://test.com' }
    let(:timestamp) { Time.now.to_i * 1000 }

    let(:rsa) do
      key = OpenSSL::PKey::RSA.generate(2048, 3)
      OpenSSL::PKey::RSA.new(key)
    end

    let(:secure_sig) do
      Base64.encode64(
        rsa.private_encrypt("#{site_name}:#{sdk_url}:#{timestamp}").to_s
      )
    end

    let(:params) do
      {
        sdk_url: CGI.escape(sdk_url),
        timestamp:,
        secure_sig:,
        site_name: CGI.escape(site_name),
        current_user_uuid: user.provider_uuid
      }
    end

    before do
      ENV['DUDA_PUBLIC_KEY'] = rsa
        .public_key
        .to_s
        .to_s.sub('-----BEGIN PUBLIC KEY-----', '')
        .sub('-----END PUBLIC KEY-----', '')
        .strip
    end

    subject do
      get :sso, params:
    end

    it 'signs the user in and redirects them' do
      subject

      expect(response).to have_http_status(302)
    end
  end

  describe 'POST /integrations/websitebuilder/webhooks' do
    let(:provider_uuid) { SecureRandom.uuid }
    let(:event_type) { 'DOMAIN_UPDATED' }

    let!(:site) { create(:site, provider: 'duda', uuid: provider_uuid) }

    let(:data) do
      {
        'domain' => nil,
        'subdomain' => 'mysite.com'
      }
    end

    let(:resource_data) do
      {
        'site_name' => provider_uuid
      }
    end

    let(:params) do
      {
        'event_type' => event_type,
        'data' => data,
        'resource_data' => resource_data
      }
    end

    subject do
      get :webhook, params:
    end

    it 'updates the site url' do
      expect { subject }.to change { site.reload.url }.to("https://#{data['subdomain']}")
    end

    it 'returns okay' do
      subject

      expect(response).to have_http_status(200)
      expect(json_body).to eq('status' => 'OK')
    end
  end
end
