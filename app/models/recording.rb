# frozen_string_literal: true

require 'uri'

# Permanent storage for recordings
class Recording < ApplicationRecord
  belongs_to :site
  belongs_to :visitor

  has_many :notes, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :pages, dependent: :destroy

  has_and_belongs_to_many :tags

  INDEX = Rails.configuration.elasticsearch['recordings_index']

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device
    {
      browser_name: user_agent.browser,
      browser_details: "#{user_agent.browser} Version #{user_agent.version}",
      viewport_x: viewport_x,
      viewport_y: viewport_y,
      device_type: user_agent.mobile? ? 'Mobile' : 'Computer',
      useragent: useragent
    }
  end

  def page_count
    pages.size
  end

  def start_page
    pages.first.url
  end

  def exit_page
    pages.last.url
  end

  def duration
    (disconnected_at || 0) - (connected_at || 0)
  end

  def language
    Locale.get_language(locale)
  end

  def previous_recording
    recordings = site.recordings.where(deleted: false).order('connected_at DESC')
    index = recordings.index(self)
    index.zero? ? nil : recordings[index - 1]
  end

  def next_recording
    recordings = site.recordings.where(deleted: false).order('connected_at DESC')
    index = recordings.index(self)
    index >= recordings.size ? nil : recordings[index + 1]
  end

  def to_h
    {
      id: id,
      site_id: site.id,
      session_id: session_id,
      locale: locale,
      language: language,
      duration: duration,
      date_time: Time.at(disconnected_at / 1000).utc.iso8601,
      connected_at: connected_at,
      disconnected_at: disconnected_at,
      page_count: pages.all.size,
      page_views: pages.all.map(&:url),
      start_page: start_page,
      exit_page: exit_page,
      device: device,
      visitor: {
        id: visitor.id,
        visitor_id: visitor.visitor_id
      }
    }
  end
end
