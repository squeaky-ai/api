# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataRetentionJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  context 'when there are no jobs to delete' do
    it 'does not enqueue anything' do
      expect { subject }.not_to change { Recording.all.count }
    end
  end

  context 'when there are some recordings to delete' do
    let(:site) { create(:site) }
    let(:now) { now = Time.now}

    let!(:recording_1) { create(:recording, site:, created_at: now) }
    let!(:recording_2) { create(:recording, site:, created_at: now) }
    let!(:recording_3) { create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 1.day) }
    let!(:recording_4) { create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 5.days) }
    let!(:recording_5) { create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 10.days) }


    it 'enqueues ones that need deleting' do
      subject
      expect(RecordingDeleteJob).to have_been_enqueued.exactly(1).times
        .with(match_array([recording_3.id, recording_4.id, recording_5.id]))
    end
  end

  context 'when the site has unlimited storage' do
    let(:site) { create(:site) }

    before do
      now = Time.now

      site.plan.update(data_storage_months: -1)

      create(:recording, site:, created_at: now)
      create(:recording, site:, created_at: now)
      create(:recording, site:, created_at: now - 1.months)
      create(:recording, site:, created_at: now - 6.months)
      create(:recording, site:, created_at: now - 1.year)
    end

    it 'does not enqueue anything' do
      expect(RecordingDeleteJob).not_to have_been_enqueued
    end
  end
end
