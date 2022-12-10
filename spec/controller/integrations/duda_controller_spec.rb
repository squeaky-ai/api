# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::DudaController, type: :controller do
  describe 'POST /integrations/websitebuilder/install' do
    let(:account_owner_uuid) { SecureRandom.uuid }
    let(:installer_account_uuid) { SecureRandom.uuid }
    let(:site_name) { SecureRandom.uuid }
    let(:account_name) { 'account@site.com' }
    let(:api_endpoint) { 'https://api-endpoint.com' }

    let(:first_name) { 'Bob' }
    let(:last_name) { 'Dylan' }
    let(:email) { 'bob@dylan.com' }

    let(:params) do
      {
        account_owner_uuid:, 
        installer_account_uuid:, 
        site_name:, 
        api_endpoint:
      }
    end

    let(:site_response_body) do
      {
        'site_default_domain' => 'https://my-domain.com',
        'site_name' => site_name,
        'account_name' => account_name
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

    before do
      ENV['DUDA_USERNAME'] = 'username'
      ENV['DUDA_PASSWORD'] = 'password'

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/sites/multiscreen/#{site_name}", anything)
        .and_return(site_response)

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/accounts/#{account_name}", anything)
        .and_return(user_response)
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
end
