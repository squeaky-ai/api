# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Auth do
  describe '#valid?' do
    subject { described_class.new(**params).valid? }

    context 'when some of the params are missing' do
      let(:params) do
        {
          sdk_url: 'https://test.com',
          timestamp: nil,
          secure_sig: '',
          site_name: 'Squeaky',
          current_user_uuid: SecureRandom.uuid
        }
      end

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when the signature is invalid' do
      let(:site_name) { 'squeaky' }
      let(:sdk_url) { 'https://test.com' }
      let(:timestamp) { Time.current.to_i }

      let(:rsa) do
        key = OpenSSL::PKey::RSA.generate(2048, 3)
        OpenSSL::PKey::RSA.new(key)
      end

      let(:secure_sig) { 'definitely_a_fake_token' }

      let(:params) do
        {
          sdk_url:,
          timestamp:,
          secure_sig:,
          site_name:,
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

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end

    context 'when the signature is valid' do
      let(:site_name) { 'squeaky' }
      let(:sdk_url) { 'https://test.com' }
      let(:timestamp) { Time.current.to_i * 1000 }

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

      it 'returns true' do
        expect(subject).to eq(true)
      end
    end

    context 'when the signature is valid but the timestamp is old' do
      let(:site_name) { 'squeaky' }
      let(:sdk_url) { 'https://test.com' }
      let(:timestamp) { (Time.current.to_i * 1000) - 160000 } # the limit is 120s / 120000ms

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

      it 'returns false' do
        expect(subject).to eq(false)
      end
    end
  end
end
