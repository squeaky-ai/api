# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::FeedbackSentiment do
  let(:site) { create(:site) }
  let(:from_date) { to_date - 1.week }
  let(:to_date) { Time.current }

  subject { described_class.fetch(site, from_date.to_date, to_date.to_date) }

  context 'when sentiment is disabled' do
    it 'returns the expected response' do
      expect(subject).to eq(enabled: false, score: 0.0)
    end
  end

  context 'when sentiment is enabled' do
    before do
      create(:feedback, site:, sentiment_enabled: true)

      recording_1 = create(:recording, site:, disconnected_at: (from_date + 1.day).to_time.to_i * 1000)
      recording_2 = create(:recording, site:, disconnected_at: (from_date + 2.days).to_time.to_i * 1000)
      recording_3 = create(:recording, site:, disconnected_at: (from_date + 3.days).to_time.to_i * 1000)

      create(:sentiment, recording: recording_1, score: 7)
      create(:sentiment, recording: recording_2, score: 3)
      create(:sentiment, recording: recording_3, score: 5)
    end

    it 'returns the expected response' do
      expect(subject).to eq(enabled: true, score: 5.0)
    end
  end
end
