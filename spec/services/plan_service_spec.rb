# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlanService do
  describe '.alert_if_exceeded' do
    context 'when the plan has not been exceeded' do
      let(:site) { create(:site) }

      subject { PlanService.alert_if_exceeded(site) }

      it 'does not send an email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it 'does not add the lock in Redis' do
        subject
        expect(Cache.redis.get("plan_exeeded_alerted::#{site.id}")).to eq(nil)
      end
    end

    context 'when the plan has been exceeded and the email has not been sent' do
      let(:site) { create(:site_with_team) }

      before do
        allow_any_instance_of(Site).to receive(:recording_count_exceeded?).and_return(true)
        allow(SiteMailer).to receive(:plan_exceeded).and_call_original
      end

      subject { PlanService.alert_if_exceeded(site) }

      it 'sends an email' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'includes the correct params' do
        subject
        expect(SiteMailer).to have_received(:plan_exceeded).with(
          site,
          {
            monthly_recording_count: 1000,
            next_plan: 'Light'
          },
          site.owner.user
        )
      end

      it 'adds the lock in Redis' do
        subject
        expect(Cache.redis.get("plan_exeeded_alerted::#{site.id}")).to eq('1')
      end

      it 'should expire at the end of the month' do
        subject
        ttl = Cache.redis.ttl("plan_exeeded_alerted::#{site.id}")
        expect(ttl + Time.now.to_i).to be_within(10).of(Time.now.end_of_month.to_i)
      end
    end

    context 'when the plan has been exceeded and the email has already been set' do
      let(:site) { create(:site_with_team) }

      before do
        Cache.redis.set("plan_exeeded_alerted::#{site.id}", '1')
        allow_any_instance_of(Site).to receive(:recording_count_exceeded?).and_return(true)
      end

      subject { PlanService.alert_if_exceeded(site) }

      it 'does not send an email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
    end
  end
end
