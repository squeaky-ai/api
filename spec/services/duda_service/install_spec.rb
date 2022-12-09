# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Install do
  describe '#install_all!' do
    let(:account_owner_uuid) { SecureRandom.uuid }
    let(:installer_account_uuid) { SecureRandom.uuid }
    let(:site_name) { SecureRandom.uuid }
    let(:api_endpoint) { 'https://api-endpoint.com' }

    let(:uuid) { site_name }
    let(:domain) { 'https://my-domain.com' }

    let(:site_response_body) do
      {
        'site_default_domain' => domain,
        'site_name' => site_name
      }
    end

    let(:site_response) { double(:site_response, body: site_response_body) }

    before do
      ENV['SQUEAKY_DUDA_USERNAME'] = 'username'
      ENV['SQUEAKY_DUDA_PASSWORD'] = 'password'

      allow(HTTParty).to receive(:get)
        .with("#{api_endpoint}/api/sites/multiscreen/#{site_name}", anything)
        .and_return(site_response)
    end

    subject do
      described_class.new(
        account_owner_uuid:,
        installer_account_uuid:,
        site_name:,
        api_endpoint:
      ).install_all!
    end

    it 'creates a site with the params' do
      subject
      site = Site.find_by(uuid: site_name)
      expect(site.uuid).to eq(uuid)
      expect(site.name).to eq('TODO')
      expect(site.url).to eq(domain)
    end

    it 'creates an owner with the account owner uuid' do
      subject

      site = Site.find_by(uuid: site_name)
      user = User.find_by(provider_uuid: account_owner_uuid)

      expect(user).not_to be_nil
      expect(user.provider).to eq('duda')
      expect(user.owner_for?(site)).to eq(true)
    end

    it 'creates an other user with the installer owner uuid' do
      subject

      site = Site.find_by(uuid: site_name)
      user = User.find_by(provider_uuid: installer_account_uuid)

      expect(user).not_to be_nil
      expect(user.provider).to eq('duda')
      expect(user.admin_for?(site)).to eq(true)
    end

    context 'when the owner and installer are the same person' do
      let(:user_uuid) { SecureRandom.uuid }
      let(:account_owner_uuid) { user_uuid }
      let(:installer_account_uuid) { user_uuid }

      it 'only creates one user' do
        subject

        expect { subject }.to change { User.all.size }.by(1)
      end
    end
  end
end
