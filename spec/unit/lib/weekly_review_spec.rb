# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReview do
  describe '#site' do
    let(:site) { create(:site) }
    let(:from_date) { Date.new(2022, 02, 07) }
    let(:to_date) { Date.new(2022, 02, 13) }

    let(:instance) { described_class.new(site.id, from_date, to_date) }

    subject { instance.site }

    it 'returns the site' do
      expect(subject).to eq site
    end
  end

  describe '#members' do
    let(:site) { create(:site) }
    let(:from_date) { Date.new(2022, 02, 07) }
    let(:to_date) { Date.new(2022, 02, 13) }

    let(:team_1) { create(:team, site: site, role: Team::MEMBER) }
    let(:team_2) { create(:team, site: site, role: Team::MEMBER) }

    let(:instance) { described_class.new(site.id, from_date, to_date) }

    subject { instance.members }

    it 'returns the team members' do
      expect(subject).to eq([team_1, team_2])
    end
  end

  describe '#to_h' do
    let(:site) { create(:site) }
    let(:from_date) { Date.new(2022, 02, 07) }
    let(:to_date) { Date.new(2022, 02, 13) }

    let(:visitor_1) { create(:visitor) }
    let(:visitor_2) { create(:visitor) }
    let(:visitor_3) { create(:visitor) }

    before do
      visitor_1.update(new: true)
      visitor_2.update(new: true)
      visitor_3.update(new: false)

      create(
        :recording, 
        site:,
        connected_at: 1644331421390,
        disconnected_at: 1644331425390,
        visitor: visitor_1, 
        viewed: true, 
        referrer: 'https://google.com',
        browser: 'Chrome',
        country_code: 'GB'
      )
      create(
        :recording, 
        site:, 
        connected_at: 1644718421390,
        disconnected_at: 1644718425390,
        visitor: visitor_2, 
        viewed: true, 
        referrer: 'https://google.com',
        browser: 'Firefox',
        country_code: 'SE'
      )
      create(
        :recording, 
        site:, 
        connected_at: 1644718420390,
        disconnected_at: 1644718422390,
        visitor: visitor_2, 
        viewed: true, 
        referrer: nil,
        browser: 'Firefox',
        country_code: 'GB',
        pages: [
          create(:page, url: '/test')
        ]
      )
      create(
        :recording, 
        site:, 
        connected_at: 1644718420390,
        disconnected_at: 1644718421390,
        visitor: visitor_2, 
        viewed: false, 
        referrer: nil,
        browser: 'Chrome',
        country_code: 'SE'
      )
      create(
        :recording, 
        site:, 
        connected_at: 1644718322390,
        disconnected_at: 1644718325390,
        visitor: visitor_3, 
        viewed: false, 
        referrer: 'https://google.com',
        browser: 'Chrome',
        country_code: 'GB',
        pages: [
          create(:page, url: '/test'),
          create(:page, url: '/sausage')
        ]
      )
    end

    let(:instance) { described_class.new(site.id, from_date, to_date) }

    subject { instance.to_h }

    it 'returns the big chungus hash' do
      expect(subject).to eq(
        total_visitors: 3,
        new_visitors: 2,
        total_recordings: 5,
        new_recordings: 2,
        average_session_duration: {
          raw: 2800,
          formatted: '0m 2s'
        },
        average_session_duration_trend: {
          trend: '0m 2s',
          direction: 'up'
        },
        pages_per_session: {
          raw: 1.6,
          formatted: '1.60'
        },
        pages_per_session_trend: {
          trend: '1.60',
          direction: 'up'
        },
        busiest_day: 'Sunday',
        biggest_referrer_url: 'https://google.com',
        most_popular_country: 'United Kingdom',
        most_popular_browser: 'Chrome',
        most_popular_visitor: {
          id: visitor_2.id,
          visitor_id: visitor_2.visitor_id
        },
        most_popular_page_url: '/test'
      )
    end
  end
end
