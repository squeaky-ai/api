# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe ApplicationCable::Connection, type: :channel do
  context 'when the params are missing' do
    it 'rejects the connection' do
      expect { connect '/cable' }.to have_rejected_connection
    end
  end

  context 'when the params are valid but the site does not exist' do
    let(:query) { "?site_id=#{SecureRandom.uuid}&viewer_id=#{SecureRandom.uuid}&session_id=#{SecureRandom.uuid}" }

    it 'rejects the connection' do
      expect { connect "/cable#{query}" }.to have_rejected_connection
    end
  end

  context 'when the params are valid and the site exists, but the origin is wrong' do
    let(:site) { create_site }
    let(:query) { "?site_id=#{site.uuid}&viewer_id=#{SecureRandom.uuid}&session_id=#{SecureRandom.uuid}" }
    let(:headers) { { 'origin' => Faker::Internet.url } }

    it 'rejects the connection' do
      expect { connect "/cable#{query}", headers: headers }.to have_rejected_connection
    end
  end

  context 'when the params are valid and the site exist, and the origin is correct' do
    let(:site) { create_site }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:query) { "?site_id=#{site.uuid}&viewer_id=#{viewer_id}&session_id=#{session_id}" }
    let(:headers) { { 'origin' => site.url } }

    it 'accepts the connection' do
      connect "/cable#{query}", headers: headers

      expect(connection.current_user).to eq(
        {
          site: site,
          viewer_id: viewer_id,
          session_id: session_id
        }
      )
    end
  end
end
