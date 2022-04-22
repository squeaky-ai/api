# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe '#name' do
    let(:instance) { described_class.new(tier: 2) }

    subject { instance.name }

    it 'returns the name of the plan' do
      expect(subject).to eq 'Plus'
    end
  end

  describe '#exceeded?' do
    context 'when the there are no locked recordings' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(tier: 3) }
  
      before do
        site.update(plan: instance)
      end
  
      subject { instance.exceeded? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end

    context 'when the there are locked recordings' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(tier: 3) }
  
      before do
        allow(instance).to receive(:recordings_locked_count).and_return 5

        site.update(plan: instance)
      end
  
      subject { instance.exceeded? }

      it 'returns true' do
        expect(subject).to eq true
      end
    end
  end

  describe '#invalid?' do
    context 'when they are on the free tier' do
      let(:instance) { described_class.new(tier: 0) }

      subject { instance.invalid? }

      it 'returns false' do
        expect(subject).to eq false
      end
    end

    context 'when they are on a paid tier and the billing is invalid' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(tier: 3) }

      before do
        create(:billing, status: Billing::INVALID, site:, user: site.owner.user)
        
        site.update(plan:instance)
      end

      subject { instance.invalid? }

      it 'returns true' do
        expect(subject).to eq true
      end
    end

    context 'when they are on a paid tier and the billing is valid' do
      let(:site) { create(:site_with_team) }
      let(:instance) { described_class.new(tier: 3) }

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
      let(:instance) { described_class.new(tier: 0) }

      subject { instance.max_monthly_recordings }

      it 'returns the plan default' do
        expect(subject).to eq 1000
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(tier: 0) }

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
      let(:instance) { described_class.new(tier: 0) }

      subject { instance.data_storage_months }

      it 'returns the plan default' do
        expect(subject).to eq 6
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(tier: 0) }

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
      let(:instance) { described_class.new(tier: 0) }

      subject { instance.response_time_hours }

      it 'returns the plan default' do
        expect(subject).to eq 168
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(tier: 0) }

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
      let(:instance) { described_class.new(tier: 0) }

      subject { instance.support }

      it 'returns the plan default' do
        expect(subject).to eq(['Email'])
      end
    end

    context 'when there is an override set' do
      let(:instance) { described_class.new(tier: 0) }

      before do
        instance.support = ['Email', 'Afternoon Tea']
      end

      subject { instance.support }

      it 'returns the override' do
        expect(subject).to eq ['Email', 'Afternoon Tea']
      end
    end
  end

  describe '#recordings_locked_count' do
    let(:site) { create(:site) }
    let(:instance) { described_class.new(tier: 0) }

    before do
      create(:recording, status: Recording::ACTIVE, site:)
      create(:recording, status: Recording::ACTIVE, site:)
      create(:recording, status: Recording::LOCKED, site:)
      create(:recording, status: Recording::LOCKED, site:)
      create(:recording, status: Recording::LOCKED, site:)
      create(:recording, status: Recording::DELETED, site:)

      site.update(plan: instance)
    end

    subject { instance.recordings_locked_count }

    it 'returns the number of locked recordings' do
      expect(subject).to eq 3
    end
  end

  describe '#visitors_locked_count' do
    let(:site) { create(:site) }
    let(:instance) { described_class.new(tier: 0) }

    before do
      create(:visitor)
      create(:visitor)
      
      create(:recording, site:, status: Recording::LOCKED, visitor: create(:visitor))
      create(:recording, site:, status: Recording::LOCKED, visitor: create(:visitor))
      create(:recording, site:, status: Recording::DELETED, visitor: create(:visitor))

      site.update(plan: instance)
    end

    subject { instance.visitors_locked_count }

    it 'returns the number of locked visitors' do
      expect(subject).to eq 2
    end
  end
end
