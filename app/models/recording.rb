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
    (disconnected_at || 0) - (connected_at || 0)
  end

  def language
    Locale.get_language(locale)
  end

  def previous_recording
    recordings = site.recordings
    index = recordings.index(self)
    index.zero? ? nil : recordings[index - 1]
  end

  def next_recording
    recordings = site.recordings
    index = recordings.index(self)
    index >= recordings.size ? nil : recordings[index + 1]
  end
end
