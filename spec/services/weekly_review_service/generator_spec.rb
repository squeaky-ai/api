# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewService::Generator do
  let(:site) { create(:site) }

  let(:member_1) { create(:team, site:) }
  let(:member_2) { create(:team, site:) }

  let(:from_date) { Time.zone.today }
  let(:to_date) { from_date - 1.week }

  let(:date_range) { DateRange.new(from_date:, to_date:) }

  let(:instance) { described_class.new(site_id: site.id, from_date:, to_date:) }

  before do
    allow(WeeklyReviewService::TotalVisitors).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(5)
    allow(WeeklyReviewService::NewVisitors).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(3)
    allow(WeeklyReviewService::TotalRecordings).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(5)
    allow(WeeklyReviewService::NewRecordings).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(1)
    allow(WeeklyReviewService::AverageSessionDuration).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(raw: 5000, formatted: '0m 5s')
    allow(WeeklyReviewService::AverageSessionDuration).to receive(:fetch).with(site, date_range.trend_from, date_range.trend_to).and_return(raw: 2000, formatted: '0m 2s')
    allow(WeeklyReviewService::PagesPerSession).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(raw: 6, formatted: '6.00')
    allow(WeeklyReviewService::PagesPerSession).to receive(:fetch).with(site, date_range.trend_from, date_range.trend_to).and_return(raw: 4, formatted: '4.00')
    allow(WeeklyReviewService::BusiestDay).to receive(:fetch).with(site, date_range.from, date_range.to).and_return('Monday')
    allow(WeeklyReviewService::BiggestReferrerUrl).to receive(:fetch).with(site, date_range.from, date_range.to).and_return('https://google.com')
    allow(WeeklyReviewService::MostPopularCountry).to receive(:fetch).with(site, date_range.from, date_range.to).and_return('Belgium')
    allow(WeeklyReviewService::MostPopularBrowser).to receive(:fetch).with(site, date_range.from, date_range.to).and_return('Firefox')
    allow(WeeklyReviewService::MostPopularVisitor).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(id: 1323, visitor_id: 'sdfsdfsd')
    allow(WeeklyReviewService::MostPopularPageUrl).to receive(:fetch).with(site, date_range.from, date_range.to).and_return('/contact-us')
    allow(WeeklyReviewService::FeedbackNps).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(enabled: true, score: 8)
    allow(WeeklyReviewService::FeedbackNps).to receive(:fetch).with(site, date_range.trend_from, date_range.trend_to).and_return(enabled: true, score: 7)
    allow(WeeklyReviewService::FeedbackSentiment).to receive(:fetch).with(site, date_range.from, date_range.to).and_return(enabled: true, score: 5)
    allow(WeeklyReviewService::FeedbackSentiment).to receive(:fetch).with(site, date_range.trend_from, date_range.trend_to).and_return(enabled: true, score: 6)
  end

  describe '#site' do
    it 'returns the site' do
      expect(instance.site).to eq(site)
    end
  end

  describe '#members' do
    it 'returns the team members' do
      expect(instance.members).to match_array([member_1, member_2])
    end
  end

  describe '#to_h' do
    it 'returns the expected structure' do
      expect(instance.to_h).to eq(
        total_visitors: 5,
        new_visitors: 3,
        total_recordings: 5,
        new_recordings: 1,
        average_session_duration: {
          raw: 5000,
          formatted: '0m 5s'
        },
        average_session_duration_trend: {
          trend: '0m 3s',
          direction: 'up'
        },
        pages_per_session: {
          raw: 6,
          formatted: '6.00'
        },
        pages_per_session_trend: {
          trend: '2.00',
          direction: 'up'
        },
        busiest_day: 'Monday',
        biggest_referrer_url: 'https://google.com',
        most_popular_country: 'Belgium',
        most_popular_browser: 'Firefox',
        most_popular_visitor: {
          id: 1323,
          visitor_id: 'sdfsdfsd'
        },
        most_popular_page_url: '/contact-us',
        feedback_nps: {
          enabled: true,
          score: 8
        },
        feedback_nps_trend: {
          trend: '1.00',
          direction: 'up'
        },
        feedback_sentiment: {
          enabled: true,
          score: 5
        },
        feedback_sentiment_trend: {
          trend: '-1.00',
          direction: 'down'
        }
      )
    end
  end
end
