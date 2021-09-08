# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe ApplicationCable::Connection, :type => :channel do
  describe 'when no params are provided' do
    it 'rejects the connection' do
      expect { connect '/gateway' }.to have_rejected_connection
    end
  end

  describe 'when only some of the params are provided' do
    let(:params) { "?site_id=#{SecureRandom.uuid}" }

    it 'rejects the connection' do
      expect { connect "/gateway#{params}" }.to have_rejected_connection
    end
  end

  describe 'when all of the params exist but the site does not' do
    let(:params) { "?site_id=#{SecureRandom.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'rejects the connection' do
      expect { connect "/gateway#{params}" }.to have_rejected_connection
    end
  end

  describe 'when all of the params exist, so does the site, but the origin does not match' do
    let(:site) { create_site(url: 'http://not-my-domain.com') }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'rejects the connection' do
      expect { connect "/gateway#{params}" }.to have_rejected_connection
    end
  end

  describe 'when all the params exist, so does the site, and the origin is correct' do
    let(:origin) { 'http://my-domain.com' }
    let(:site) { create_site(url: origin) }
    let(:params) { "?site_id=#{site.uuid}&visitor_id=#{SecureRandom.base36}&session_id=#{SecureRandom.base36}" }

    it 'successfully connects' do
      expect(connect "/gateway#{params}", headers: { origin: origin }).not_to be nil
    end
  end
end
