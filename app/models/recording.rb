# frozen_string_literal: true

require 'uri'

# Permanent storage for recordings
class Recording < ApplicationRecord
  belongs_to :site

  has_many :tags, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :events, dependent: :destroy

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device_type
    user_agent.mobile? ? 'Mobile' : 'Computer'
  end

  def browser
    user_agent.browser
  end

  def browser_string
    "#{browser} Version #{user_agent.version}"
  end

  def page_count
    page_views.size || 0
  end

  def start_page
    page_views.first || '/'
  end

  def exit_page
    page_views.last || '/'
  end

  def duration
    start = connected_at || 0
    finish = disconnected_at || 0

    (finish - start) / 1000
  end

  def duration_string
    return '00:00' if duration.zero? || duration.negative?

    Time.at(duration).utc.strftime('%M:%S')
  end

  def language
    Locale.get_language(locale)
  end

  def date_string
    return nil if connected_at.nil?

    date = Time.at(connected_at / 1000).utc
    date.strftime("#{date.day.ordinalize} %B %Y")
  end
end
