# frozen_string_literal: true

require 'uri'

# Permanent storage for recordings. The #to_h method should
# be used to return data to the front end as it includes a
# bunch of stuff preformatted
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

  def to_h
    {
      id: session_id,
      site_id: site_id.to_s,
      viewer_id: viewer_id,
      active: active,
      language: language,
      duration: duration,
      duration_string: duration_string,
      pages: page_views,
      page_count: page_count,
      start_page: start_page,
      exit_page: exit_page,
      device_type: device_type,
      browser: browser,
      browser_string: browser_string,
      viewport_x: viewport_x,
      viewport_y: viewport_y,
      date_string: date_string,
      tags: tags.map(&:to_h),
      notes: notes.map(&:to_h),
      # No way we can schema this in GQL so just stringify it 🚀
      events: events.map(&:to_h).to_json,
      timestamp: disconnected_at || 0
    }
  end
end
