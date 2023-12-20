# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::BusiestDay do
  let(:site) { create(:site) }
  let(:from_date) { to_date - 1.week }
  let(:to_date) { Time.current }

  subject { described_class.fetch(site, from_date.to_date, to_date.to_date) }

  context 'when there are no recordings' do
    it 'returns the expected response' do
      expect(subject).to eq(nil)
    end
  end

  context 'when there are recordings' do
    before do
      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 1.day).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 2.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
      end
    end

    it 'returns the expected response' do
      day = Date.strptime((from_date + 3.days).iso8601, '%Y-%m-%d').strftime('%A')
      expect(subject).to eq(day)
    end
  end
end
