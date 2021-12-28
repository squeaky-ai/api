# frozen_string_literal: true

require 'uri'

class Recording < ApplicationRecord
  belongs_to :site
  belongs_to :visitor, counter_cache: true

  has_many :notes, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :pages, dependent: :destroy

  has_one :nps
  has_one :sentiment

  has_and_belongs_to_many :tags

  ACTIVE = 0
  LOCKED = 1
  DELETED = 2

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device
    {
      browser_name: browser,
      browser_details: "#{browser} Version #{user_agent.version}",
      viewport_x: viewport_x,
      viewport_y: viewport_y,
      device_x: device_x,
      device_y: device_y,
      device_type: device_type,
      useragent: useragent
    }
  end

  def page_count
    ordered_pages.size
  end

  def start_page
    ordered_pages.first.url
  end

  def exit_page
    ordered_pages.last.url
  end

  def page_views
    ordered_pages.map(&:url)
  end

  def duration
    (disconnected_at || 0) - (connected_at || 0)
  end

  def language
    Locale.get_language(locale)
  end

  def previous_recording
    recordings = site.recordings.where(status: Recording::ACTIVE).order('connected_at DESC')
    index = recordings.index(self)
    index.zero? ? nil : recordings[index - 1]
  end

  def next_recording
    recordings = site.recordings.where(status: Recording::ACTIVE).order('connected_at DESC')
    index = recordings.index(self)
    index >= recordings.size ? nil : recordings[index + 1]
  end

  def deleted?
    status == Recording::DELETED
  end

  private

  def ordered_pages
    @ordered_pages ||= pages.sort_by(&:entered_at)
  end
end
