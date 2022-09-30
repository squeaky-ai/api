# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClickHouse::ScrollEvent, type: :model do
  describe '.create_from_session' do
    let(:message) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.uuid,
        session_id: SecureRandom.uuid
      }
    end

    let(:site) { create(:site) }
    let(:recording) { create(:recording, site:) }
    let(:session) { Session.new(message) }
    
    before do
      events_fixture = require_fixture('events.json', compress: true)
      allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
    end

    subject { described_class.create_from_session(recording, session) }

    it 'inserts all the scrolls in ClickHouse' do
      subject

      results = ClickHouse.connection.select_value("
        SELECT COUNT(*)
        FROM scroll_events
        WHERE site_id = #{site.id} AND recording_id = #{recording.id}
      ")

      expect(results).to eq 40
    end
  end
end
