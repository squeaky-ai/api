# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/site
class SitePreview < ActionMailer::Preview
  def weekly_review
    site = Site.first
    user = site.team.first.user

    data = {
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
        id: 1,
        visitor_id: '234dfgdfg'
      },
      most_popular_page_url: '/test',
      feedback_nps: {
        enabled: true,
        score: 33.33
      },
      feedback_nps_trend: {
        direction: 'up', 
        trend: '33.33'
      },
      feedback_sentiment: {
        enabled: true, 
        score: 4.33
      },
      feedback_sentiment_trend: {
        direction: 'up', 
        trend: '4.33'
      }
    }

    SiteMailer.weekly_review(site, data, user)
  end

  def plan_exceeded
    site = Site.first
    user = site.team.first.user

    data = {
      monthly_recording_count: 5000,
      next_plan_name: 'Light'
    }

    SiteMailer.plan_exceeded(site, data, user)
  end

  def new_feedback
    site = Site.find(1)
    user = site.team.first.user

    data = {
      site:,
      nps: site.nps,
      sentiment: site.sentiments
    }

    SiteMailer.new_feedback(data, user)
  end
end
