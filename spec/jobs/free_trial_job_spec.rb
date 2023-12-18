# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FreeTrialJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now(site_id) }

  context 'when the site no longer exists' do
    let(:site_id) { 1231231 }

    it 'does nothing' do
      expect { subject }.not_to raise_error
    end
  end

  context 'when the site exists and is still on the free plan' do
    let(:site) { create(:site) }
    let(:site_id) { site.id }

    before do
      site.plan.start_free_trial!
    end

    it 'ends the trial' do
      expect { subject }.to change { site.reload.plan.max_monthly_recordings }
        .from(1500)
        .to(500)
        .and change { site.reload.plan.features_enabled }
        .from(Types::Plans::Feature.values.keys)
        .to(%w[dashboard visitors recordings site_analytics heatmaps_click_positions])
    end
  end

  context 'when the site exists but has upgraded to a paid plan' do
    let(:site) { create(:site) }
    let(:site_id) { site.id }

    before do
      site.plan.change_plan!('f20c93ec-172f-46c6-914e-6a00dff3ae5f')
    end

    it 'does not change the monthly recordings' do
      expect { subject }.not_to(change { site.reload.plan.max_monthly_recordings })
    end

    it 'does not change the features' do
      expect { subject }.not_to(change { site.reload.plan.features_enabled })
    end
  end
end
