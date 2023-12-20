# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::FeedbackNps do
  let(:site) { create(:site) }
  let(:from_date) { to_date - 1.week }
  let(:to_date) { Time.current }

  subject { described_class.fetch(site, from_date.to_date, to_date.to_date) }

  context 'when nps is disabled' do
    it 'returns the expected response' do
      expect(subject).to eq(enabled: false, score: 0)
    end
  end

  context 'when nps is enabled' do
    before do
      create(:feedback, site:, nps_enabled: true)

      allow(Nps).to receive(:get_score_between)
        .with(site.id, from_date.to_date, to_date.to_date)
        .and_return(5)
    end

    it 'returns the expected response' do
      expect(subject).to eq(enabled: true, score: 5)
    end
  end
end
