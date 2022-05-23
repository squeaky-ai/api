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
  ALL = [0, 1, 2].freeze

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device
    {
      browser_name: browser,
      browser_details: "#{browser} Version #{user_agent.version}",
      viewport_x:,
      viewport_y:,
      device_x:,
      device_y:,
      device_type:,
      useragent:
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
    (self[:disconnected_at] || 0) - (self[:connected_at] || 0)
  end

  def language
    Locale.get_language(locale)
  end

  def connected_at
    epoch_to_timestamp(self[:connected_at])
  end

  def disconnected_at
    epoch_to_timestamp(self[:disconnected_at])
  end

  def country_name
    Countries.get_country(country_code)
  end

  def deleted?
    status != Recording::ACTIVE
  end

  private

  def ordered_pages
    @ordered_pages ||= pages.sort_by(&:entered_at)
  end

  def epoch_to_timestamp(epoch)
    # First check that the value we have is valid, as
    # TZInfo::Timezone.get will raise if the value is
    # nil, or is not in the list
    valid_identifier = TZInfo::Timezone.all_identifiers.include?(timezone)
    # Get the offset by the timezone of the user, or
    # default to 0 if it's not valid
    offset = valid_identifier ? TZInfo::Timezone.get(timezone).utc_offset : 0
    Time.at(epoch / 1000).getutc + offset
  end
end
