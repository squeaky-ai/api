# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingDeleteJob, type: :job do
  include ActiveJob::TestHelper

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
    described_class.perform_now([site.recordings.reload.first.id])
  end

  it 'deletes the recording, visitor and all the clickhouse data' do
    subject
    site.reload

    expect(site.visitors.size).to eq(0)
    expect(site.recordings.size).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM click_events WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM cursor_events WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM custom_events WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM error_events WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM page_events WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM recordings WHERE site_id = #{site.id}")).to eq(0)
    expect(Sql::ClickHouse.select_value("SELECT COUNT(*) FROM scroll_events WHERE site_id = #{site.id}")).to eq(0)
  end

  context 'when a visitor has some other recordings that are in the data retention window' do
    let(:visitor) { create(:visitor, site_id: site.id) }

    let!(:recording_1) { create(:recording, visitor:, site:) }
    let!(:recording_2) { create(:recording, visitor:, site:) }

    subject { described_class.perform_now([recording_1]) }

    it 'does not delete the visitor' do
      subject
      site.reload

      expect(site.visitors.size).to eq(1)
      expect(site.recordings.size).to eq(1)
    end
  end
end
