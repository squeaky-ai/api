# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::MostPopularVisitor do
  let(:site) { create(:site) }
  let(:from_date) { to_date - 1.week }
  let(:to_date) { Time.current }

  subject { described_class.fetch(site, from_date.to_date, to_date.to_date) }

  context 'when there are no recordings' do
    it 'returns the expected response' do
      expect(subject).to eq(id: nil, visitor_id: nil)
    end
  end

  context 'when there are recordings' do
    let(:visitor_1) { create(:visitor, site_id: site.id) }
    let(:visitor_2) { create(:visitor, site_id: site.id) }
    let(:visitor_3) { create(:visitor, site_id: site.id) }

    before do
      ClickHouse::Recording.insert do |buffer|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          visitor_id: visitor_1.id,
          disconnected_at: (from_date + 1.day).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          visitor_id: visitor_2.id,
          disconnected_at: (from_date + 2.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          visitor_id: visitor_2.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          visitor_id: visitor_3.id,
          disconnected_at: (from_date + 3.days).to_time.to_i * 1000
        }
      end
    end

    it 'returns the expected response' do
      expect(subject).to eq(id: visitor_2.id, visitor_id: visitor_2.visitor_id)
    end
  end
end
