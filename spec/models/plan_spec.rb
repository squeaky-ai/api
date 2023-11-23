# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe '#name' do
    let(:instance) { described_class.new(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

    subject { instance.name }

    it 'returns the name of the plan' do
      expect(subject).to eq 'Plus'
    end
  end

  describe '#exceeded?' do
    let(:site) { create(:site_with_team) }
    let(:instance) { described_class.new(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c') }

    before do
      allow(instance).to receive(:current_month_recordings_count).and_return 41234134234

      site.update(plan: instance)
    end

    subject { instance.exceeded? }

    it 'returns true' do
      expect(subject).to eq true
    end
  end

  describe '#invalid?' do
    context 'when they are on the free tier' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      subject { instance.invalid? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end

    context 'when they are on a paid tier and the billing is invalid' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c') }

      before do
        create(:billing, status: Billing::INVALID, site:, user: site.owner.user)

        site.update(plan: instance)
      end

      subject { instance.invalid? }

      it 'returns true' do
        expect(subject).to eq true
      end
    end

    context 'when they are on a paid tier and the billing is valid' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(plan_id: 'b2054935-4fdf-45d0-929b-853cfe8d4a1c') }

      before do
        create(:billing, status: Billing::VALID, site:, user: site.owner.user)

        site.update(plan: instance)
      end

      subject { instance.invalid? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end
  end

  describe '#max_monthly_recordings' do
    context 'when there is no override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      subject { instance.max_monthly_recordings }

      it 'returns the plan default' do
        expect(subject).to eq 500
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      before do
        instance.max_monthly_recordings = 9999
      end

      subject { instance.max_monthly_recordings }

      it 'returns the override' do
        expect(subject).to eq 9999
      end
    end
  end

  describe '#data_storage_months' do
    context 'when there is no override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      subject { instance.data_storage_months }

      it 'returns the plan default' do
        expect(subject).to eq 1
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      before do
        instance.data_storage_months = 100
      end

      subject { instance.data_storage_months }

      it 'returns the override' do
        expect(subject).to eq 100
      end
    end
  end

  describe '#response_time_hours' do
    context 'when there is no override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      subject { instance.response_time_hours }

      it 'returns the plan default' do
        expect(subject).to eq 336
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      before do
        instance.response_time_hours = 1
      end

      subject { instance.response_time_hours }

      it 'returns the override' do
        expect(subject).to eq 1
      end
    end
  end

  describe '#support' do
    context 'when there is no override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      subject { instance.support }

      it 'returns the plan default' do
        expect(subject).to eq(['Email'])
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      before do
        instance.support = ['Email', 'Afternoon Tea']
      end

      subject { instance.support }

      it 'returns the override' do
        expect(subject).to eq ['Email', 'Afternoon Tea']
      end
    end
  end

  describe '#start_free_trial!' do
    let(:site) { create(:site) }
    let(:instance) { site.plan }

    before do
      allow(FreeTrialMailerService).to receive(:enqueue)
    end

    subject { instance.start_free_trial! }

    it 'sets the features and max recordings' do
      expect { subject }.to change { instance.max_monthly_recordings }
        .from(500)
        .to(1500)
        .and change { instance.features_enabled }
        .from(%w[dashboard visitors recordings site_analytics heatmaps_click_positions])
        .to(Types::Plans::Feature.values.keys)
    end

    it 'enqueues the free trial job' do
      ActiveJob::Base.queue_adapter = :test

      subject

      expect(FreeTrialJob).to have_been_enqueued.exactly(1).times.with(site.id)
    end

    it 'enqueues the free trial mailer' do
      subject
      expect(FreeTrialMailerService).to have_received(:enqueue)
    end
  end

  describe '#end_free_trial!' do
    let(:site) { create(:site) }
    let(:instance) { site.plan }

    before { instance.start_free_trial! }

    subject { instance.end_free_trial! }

    it 'sets the features and max recordings' do
      expect { subject }.to change { instance.max_monthly_recordings }
        .from(1500)
        .to(500)
        .and change { instance.features_enabled }
        .from(Types::Plans::Feature.values.keys)
        .to(%w[dashboard visitors recordings site_analytics heatmaps_click_positions])
    end
  end
end
