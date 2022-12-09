# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::DudaController, type: :controller do
  describe 'GET /integrations/websitebuilder/sso' do
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
        current_user_uuid: SecureRandom.uuid
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

    it 'returns okay' do
      subject

      expect(response).to have_http_status(200)
      expect(json_body).to eq('status' => 'OK')
    end
  end
end
