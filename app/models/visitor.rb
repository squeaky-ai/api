# frozen_string_literal: true

# Visitors on sites. You're gonna have a bad time with this
# as most of the attributes don't exist on the visitor model
# but instead are inner-joined by the recordings
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
end
