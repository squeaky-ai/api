# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::PagesPerSession do
  let(:site) { create(:site) }
  let(:from_date) { to_date - 1.week }
  let(:to_date) { Time.current }

  subject { described_class.fetch(site, from_date.to_date, to_date.to_date) }

  context 'when there are no recordings' do
    it 'returns the expected response' do
      expect(subject).to eq(raw: 0.0, formatted: '0.00')
    end
  end

  context 'when there are recordings' do
    before do
      ClickHouse::PageEvent.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 1,
          exited_at: (from_date + 1.day).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 2,
          exited_at: (from_date + 2.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 3,
          exited_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 2,
          exited_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 3,
          exited_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          recording_id: 3,
          exited_at: (from_date + 3.days).to_time.to_i * 1000
        }
      end
    end

    it 'returns the expected response' do
      expect(subject).to eq(raw: 2.0, formatted: '2.00')
    end
  end
end
