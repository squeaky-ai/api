# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataRetentionJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  context 'when there are no jobs to delete' do
    it 'does not delete any recordings' do
      expect { subject }.not_to change { Recording.all.count }
    end
  end

  context 'when there are some recordings to delete' do
    let(:site) { create(:site) }

    before do
      now = Time.now

      create(:recording, site:, created_at: now)
      create(:recording, site:, created_at: now)
      create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 1.day)
      create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 5.days)
      create(:recording, site:, created_at: now - site.plan.data_storage_months.months - 10.days)
    end

    it 'deletes the ones that are older than the plan date' do
      expect { subject }.to change { site.recordings.size }.from(5).to(2)
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

    it 'deletes the ones that are older than the plan date' do
      expect { subject }.not_to change { site.recordings.size }
    end
  end
end
