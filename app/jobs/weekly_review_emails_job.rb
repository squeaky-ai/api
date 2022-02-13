# frozen_string_literal: true

class WeeklyReviewEmailsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    puts '!!'

    {
      total_visitors: 0,
      new_visitors: 0,
      total_recordings: 0,
      new_recordings: 0,
      average_session_duration: 0,
      pages_per_session: 0,
      busiest_day: 'Monday',
      biggest_referrer_url: 'https://squeaky.ai',
      most_popular_country: 'UK',
      most_popular_browser: 'Chrome',
      most_popular_visitor_id: 'ID',
      most_popular_page_url: 'https://squeaky.ai'
    }
  end
end
