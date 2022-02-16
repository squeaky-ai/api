# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteMailer, type: :mailer do
  describe 'destroyed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }
    let(:mail) { described_class.destroyed(user.email, site) }

    it 'renders the headers' do
      expect(mail.subject).to eq "The team account for #{site.name} has been deleted"
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end

  describe 'weekly_review' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    let(:data) do
      {
        total_visitors: 0,
        new_visitors: 0,
        total_recordings: 0,
        new_recordings: 0,
        average_session_duration: {
          raw: 2800,
          formatted: '00:02'
        },
        average_session_duration_trend: {
          trend: '00:02',
          direction: 'up'
        },
        pages_per_session: {
          raw: 1.0,
          formatted: '1.00'
        },
        pages_per_session_trend: {
          trend: 1,
          direction: 'up'
        },
        busiest_day: 'Monday',
        biggest_referrer_url: 'https://squeaky.ai',
        most_popular_country: 'UK',
        most_popular_browser: 'Chrome',
        most_popular_visitor: {
          id: 1,
          visitor_id: '12312312'
        },
        most_popular_page_url: 'https://squeaky.ai',
        feedback_nps: {
          enabled: true,
          score: 33.33
        },
        feedback_nps_trend: {
          direction: 'up', 
          trend: 33.33
        },
        feedback_sentiment: {
          enabled: true, 
          score: 4.33
        },
        feedback_sentiment_trend: {
          direction: 'up', 
          trend: 4.33
        }
      }
    end

    subject { described_class.weekly_review(site, data, user) }

    it 'renders the headers' do
      expect(subject.subject).to eq 'Your Week In Review'
      expect(subject.to).to eq [user.email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end

    context 'when the user has the communication disabled' do
      before do
        Communication.create(
          user_id: user.id,
          onboarding_email: true,
          weekly_review_email: false,
          monthly_review_email: true,
          product_updates_email: true,
          marketing_and_special_offers_email: true,
          knowledge_sharing_email: true
        )
      end

      it 'does not render the headers' do
        expect(subject.subject).to eq nil
        expect(subject.to).to eq nil
        expect(subject.from).to eq nil
      end
    end
  end
end
