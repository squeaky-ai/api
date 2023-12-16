# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  describe 'when no params are provided' do
    it 'rejects the connection' do
      expect { connect '/in' }.to have_rejected_connection
    end
  end

  describe 'when only some of the params are provided' do
    let(:params) { "?site_id=#{SecureRandom.uuid}" }

    it 'rejects the connection' do
      expect { connect "/in#{params}" }.to have_rejected_connection
    end
  end

  describe 'when all of the params exist but the site does not' do
    let(:params) { "?site_id=#{SecureRandom.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'rejects the connection' do
      expect { connect "/in#{params}" }.to have_rejected_connection
    end
  end

  describe 'when all of the params exist, so does the site, but the origin does not match' do
    let(:site) { create(:site, url: 'http://not-my-domain.com') }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'rejects the connection' do
      expect { connect "/in#{params}", headers: { origin: 'not_gonna_match' } }.to have_rejected_connection
    end
  end

  describe 'when all the params exist, so does the site, but the IP address is blacklisted' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create(:site, url: origin) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    before do
      site.ip_blacklist << { name: 'Foo', value: '0.0.0.0' }
      site.save
    end

    it 'rejects the connection' do
      expect { connect "/in#{params}", headers: { origin: } }.to have_rejected_connection
    end
  end

  describe 'when all the params exist, so does the site, and the origin is correct' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create(:site, url: origin) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'successfully connects' do
      expect(connect("/in#{params}", headers: { origin: })).not_to be nil
    end
  end

  describe 'when the params exist, so does the site, but the ingest is disabled' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create(:site, url: origin, ingest_enabled: false) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'rejects the connection' do
      expect { connect "/in#{params}", headers: { origin: } }.to have_rejected_connection
    end
  end

  describe 'when the params exist, so does the site, but they have exceeded their plan' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create(:site, url: origin) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    before do
      allow_any_instance_of(Plan).to receive(:exceeded?).and_return(true)
    end

    it 'rejects the connection' do
      expect { connect "/in#{params}", headers: { origin: } }.to have_rejected_connection
    end
  end

  describe 'when the params exist, so does the site, but they have not paid their bill' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create(:site, url: origin) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    before do
      allow_any_instance_of(Plan).to receive(:invalid?).and_return(true)
    end

    it 'rejects the connection' do
      expect { connect "/in#{params}", headers: { origin: } }.to have_rejected_connection
    end
  end
end
