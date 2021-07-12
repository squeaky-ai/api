# frozen_string_literal: true

# Permanent storage for recordings, although they are searched
# for in ElasticSearch. The #to_h method should be used to
# return data to the front end as it includes a bunch of stuff
# preformatted
class Recording < ApplicationRecord
  belongs_to :site

  has_many :tags, dependent: :destroy
  has_many :notes, dependent: :destroy

  INDEX = Rails.configuration.elasticsearch['recordings_index']

  def active
    false
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

  def page_count
    page_views.size
  end

  def start_page
    page_views.first
  end

  def exit_page
    page_views.last
  end

  def duration
    disconnected_at - connected_at
  end

  def duration_string
    Time.at(duration).utc.strftime('%M:%S')
  end

  def language
    Locale.get_language(locale)
  end

  def date_string
    connected_at.strftime("#{connected_at.day.ordinalize} %B %Y")
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
      timestamp: disconnected_at.to_i * 1000
    }
  end

  # Stamp the recording with the latest page view and
  # set the disconnected_at timestamp to the latest
  def stamp(path, timestamp)
    pages = page_views.push(path)
    disconnected_at = DateTime.strptime(timestamp.to_s, '%Q')
    update(page_views: pages, disconnected_at: disconnected_at)
    self
  end

  def events
    Event.new(site_id, session_id).list
  end
end
