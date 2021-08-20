# frozen_string_literal: true

# Visitors on sites
class Visitor < ApplicationRecord
  has_many :recordings

  def user_id
    visitor_id
  end

  def recording_count
    recordings.size
  end

  def first_viewed_at
    recordings.map(&:connected_at).min
  end

  def last_activity_at
    recordings.map(&:disconnected_at).max
  end

  def language
    recordings.first.language
  end

  def viewport_x
    recordings.first.viewport_x
  end

  def viewport_y
    recordings.first.viewport_y
  end

  def device_type
    recordings.first.device_type
  end

  def browser
    recordings.first.browser
  end

  def browser_string
    recordings.first.browser_string
  end

  def page_view_count
    0
  end

  def pages
    0
  end

  def average_session_duration
    0
  end

  def pages_per_session
    0
  end
end
