# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansDecorator do
  subject { described_class.new(plans: Plans.to_a, site:).decrorate }

  describe '#decrorate' do
    context 'when no site is given' do
      let(:site) { nil }
      let(:fixture) { require_fixture('plans/decorated_plans_without_site.json', symbolize_names: true) }

      it 'returns the plans' do
        expect(subject).to eq(fixture)
      end
    end

    context 'when the site is on a supported plan' do
      let(:site) { create(:site) }
      let(:fixture) { require_fixture('plans/decorated_plans_with_site.json', symbolize_names: true) }

      before { site.plan.update(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f') }

      it 'returns the plans' do
        expect(subject).to eq(fixture)
      end
    end

    context 'when the site is on a unsupported plan' do
      let(:site) { create(:site) }
      let(:fixture) { require_fixture('plans/decorated_plans_with_site_on_unsupported_plan.json', symbolize_names: true) }

      before { site.plan.update(plan_id: 'f20c93ec-172f-46c6-914e-6a00dff3ae5f') }

      it 'returns the plans' do
        expect(subject).to eq(fixture)
      end
    end
  end
end
