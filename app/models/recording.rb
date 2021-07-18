# frozen_string_literal: true

require 'uri'

# Permanent storage for recordings, although they are searched
# for in ElasticSearch. The #to_h method should be used to
# return data to the front end as it includes a bunch of stuff
# preformatted
class Recording < ApplicationRecord
  belongs_to :site

  has_many :tags, dependent: :destroy
  has_many :notes, dependent: :destroy
  has_many :events, dependent: :destroy

  INDEX = Rails.configuration.elasticsearch['recordings_index']

  def active
    Redis.current.get("active::#{site_id}_#{session_id}") == 'true'
  end

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

  def locale
    event = events.find { |e| e.type?(Event::META) }
    event ? event.data['locale'] : ''
  end

  def useragent
    event = events.find { |e| e.type?(Event::META) }
    return unless event

    event.data['useragent']
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
    ((disconnected_at - connected_at) / 1000).to_i
  end

  def page_views
    @page_views ||= events.each_with_object([]) do |event, memo|
      memo << URI(event.data['href']).path || '/' if event.type?(Event::META)
    end
  end

  def connected_at
    event = events.first
    return 0 unless event

    event.timestamp
  end

  def disconnected_at
    event = events.last
    return 0 unless event

    event.timestamp
  end

  def viewport_x
    event = events.find { |e| e.type?(Event::META) }
    return 0 unless event

    event.data['width']
  end

  def viewport_y
    event = events.find { |e| e.type?(Event::META) }
    return 0 unless event

    event.data['height']
  end

  def duration_string
    return '00:00' if duration.zero? || duration.negative?

    Time.at(duration).utc.strftime('%M:%S')
  end

  def language
    Locale.get_language(locale)
  end

  def date_string
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
      timestamp: disconnected_at.to_i
    }
  end
end
