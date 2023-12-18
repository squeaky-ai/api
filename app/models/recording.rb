# frozen_string_literal: true

class Recording < ApplicationRecord
  belongs_to :site
  belongs_to :visitor, counter_cache: true

  has_many :notes, dependent: :destroy
  has_many :pages, dependent: :destroy

  has_one :nps, dependent: :destroy
  has_one :sentiment, dependent: :destroy

  has_and_belongs_to_many :tags

  ACTIVE = 0
  ANALYTICS_ONLY = 2
  ALL = [0, 1, 2].freeze

  MOBILE_BREAKPOINT = 320
  TABLET_BREAKPOINT = 800
  DESKTOP_BREAKPOINT = 1280

  def user_agent
    @user_agent ||= UserAgent.parse(useragent)
  end

  def device
    Devices.format(
      'browser' => browser,
      'viewport_x' => viewport_x,
      'viewport_y' => viewport_y,
      'device_x' => device_x,
      'device_y' => device_y,
      'device_type' => device_type,
      'useragent' => useragent
    )
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

  def country_name
    Countries.get_country(country_code)
  end

  def analytics_only?
    status == ANALYTICS_ONLY
  end

  def self.device_expression(device)
    case device
    when 'Mobile'
      "BETWEEN #{MOBILE_BREAKPOINT} AND #{TABLET_BREAKPOINT}"
    when 'Tablet'
      "BETWEEN #{TABLET_BREAKPOINT} AND #{DESKTOP_BREAKPOINT}"
    when 'Desktop'
      ">= #{DESKTOP_BREAKPOINT}"
    end
  end

  def self.create_from_session!(session, visitor, site, status)
    create!(
      status:,
      site_id: site.id,
      visitor_id: visitor.id,
      session_id: session.session_id,
      locale: session.locale,
      device_x: session.device_x,
      browser: session.browser,
      device_type: session.device_type,
      device_y: session.device_y,
      referrer: session.referrer,
      useragent: session.useragent,
      timezone: session.timezone,
      country_code: session.country_code,
      viewport_x: session.viewport_x,
      viewport_y: session.viewport_y,
      connected_at: session.connected_at,
      disconnected_at: session.disconnected_at,
      utm_source: session.utm_source,
      utm_medium: session.utm_medium,
      utm_campaign: session.utm_campaign,
      utm_content: session.utm_content,
      utm_term: session.utm_term,
      gad: session.gad,
      gclid: session.gclid,
      activity_duration: session.activity_duration,
      inactivity: session.inactivity,
      active_events_count: session.active_events_count,
      events_key_prefix: session.events_key_prefix,
      rage_clicked: session.rage_clicked?,
      u_turned: session.u_turned?
    )
  end

  private

  def ordered_pages
    @ordered_pages ||= pages.sort_by(&:exited_at)
  end
end
