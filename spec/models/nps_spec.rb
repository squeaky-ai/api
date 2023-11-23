# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Nps, type: :model do
  describe '.get_scores_between' do
    context 'when there are no values' do
      let(:site) { create(:site) }

      let(:from_date) { Time.new(2022, 2, 2).utc }
      let(:to_date) { Time.new(2022, 2, 9).utc }

      subject { described_class.get_scores_between(site.id, from_date, to_date) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    context 'when there values' do
      let(:site) { create(:site) }
      let(:visitor) { create(:visitor) }

      let(:from_date) { Time.new(2022, 2, 2).utc }
      let(:to_date) { Time.new(2022, 2, 9).utc }

      before do
        create(:nps, score: 9, created_at: Time.new(2022, 2, 3).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 4).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 5).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 10).utc, recording: create(:recording, site:, visitor:))
      end

      subject { described_class.get_scores_between(site.id, from_date, to_date) }

      it 'returns the scores and their dates' do
        expect(subject).to match_array(
          [
            {
              score: 9,
              timestamp: Time.new(2022, 2, 3).utc
            },
            {
              score: 3,
              timestamp: Time.new(2022, 2, 4).utc
            },
            {
              score: 3,
              timestamp: Time.new(2022, 2, 5).utc
            }
          ]
        )
      end
    end
  end

  describe '.get_score_between' do
    context 'when there are no values' do
      let(:site) { create(:site) }

      let(:from_date) { Time.new(2022, 2, 2).utc }
      let(:to_date) { Time.new(2022, 2, 9).utc }

      subject { described_class.get_score_between(site.id, from_date, to_date) }

      it 'returns 0' do
        expect(subject).to eq 0
      end
    end

    context 'when there values' do
      let(:site) { create(:site) }
      let(:visitor) { create(:visitor) }

      let(:from_date) { Time.new(2022, 2, 2).utc }
      let(:to_date) { Time.new(2022, 2, 9).utc }

      before do
        create(:nps, score: 9, created_at: Time.new(2022, 2, 3).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 4).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 5).utc, recording: create(:recording, site:, visitor:))
        create(:nps, score: 3, created_at: Time.new(2022, 2, 10).utc, recording: create(:recording, site:, visitor:))
      end

      subject { described_class.get_score_between(site.id, from_date, to_date) }

      it 'returns the score' do
        expect(subject).to eq(-33.34)
      end
    end
  end
end
