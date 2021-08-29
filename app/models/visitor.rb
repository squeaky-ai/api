# frozen_string_literal: true

# Visitors on sites. You're gonna have a bad time with this
# as most of the attributes don't exist on the visitor model
# but instead are inner-joined by the recordings. Don't actually
# try and query this directly!
class Visitor < ApplicationRecord
  has_many :recordings

  def language
    Locale.get_language(locale)
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

  def attributes
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def viewed
    viewed_recording_count.positive?
  end

  def recordings_count
    {
      total: recording_count.to_i,
      new: (recording_count - viewed_recording_count).to_i
    }
  rescue StandardError
    {
      total: 0,
      new: 0
    }
  end

  def page_views_count
    {
      total: page_view_count.to_i,
      unique: unique_page_view_count.sum
    }
  rescue StandardError
    {
      total: 0,
      new: 0
    }
  end
end
