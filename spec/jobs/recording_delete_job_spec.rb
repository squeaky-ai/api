# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingDeleteJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the receording does not exist' do
    let(:recording_id) { 20424234 }

    subject { described_class.perform_now(recording_id) }

    it 'raises an error' do
      expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the recording exists' do
    let(:site) { create(:site_with_team) }

    let(:events_fixture) { require_fixture('events.json', compress: true) }

    let(:event) do
      {
        'site_id' => site.uuid,
        'session_id' => SecureRandom.base36,
        'visitor_id' => SecureRandom.base36
      }
    end

    before do
      allow(Cache.redis).to receive(:lrange).and_return(events_fixture)
    end

    subject do
      RecordingSaveJob.perform_now(event)
      described_class.perform_now(site.recordings.reload.first.id)
    end

    it 'deletes the recording and all the children' do
      subject
      site.reload

      sleep 1 # TODO: ClickHouse appears to delete async
      
      expect(site.recordings.size).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM click_events WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM cursor_events WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM custom_events WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM error_events WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM page_events WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM recordings WHERE site_id = #{site.id}")).to eq(0)
      expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM scroll_events WHERE site_id = #{site.id}")).to eq(0)
    end
  end
end