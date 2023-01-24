# frozen_string_literal: true

class Visitor < ApplicationRecord
  has_many :recordings, dependent: :destroy
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings

  alias_attribute :viewed, :viewed?

  # This allows us to set the recordings count externally,
  # like in visitiors/highlights.rb where we have fetched
  # the counts from ClickHouse
  attr_writer :recording_count

  def locale
    recordings.first.locale
  end

  def language
    Locale.get_language(locale)
  end

  def devices
    recordings.map(&:device)
  end

  def countries
    recordings_with_countries = recordings.filter(&:country_code)

    recordings_with_countries.map do |recording|
      {
        code: recording.country_code,
        name: recording.country_name
      }
    end
  end

  def linked_data
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def viewed?
    visible_recordings.filter(&:viewed).size.positive?
  end

  def first_viewed_at
    first_event = recordings.min_by(&:connected_at)
    first_event.connected_at
  end

  def last_activity_at
    last_event = recordings.max_by(&:disconnected_at)
    last_event.disconnected_at
  end

  def visible_recordings
    @visible_recordings ||= recordings.reject(&:deleted?)
  end

  def recording_count
    @recording_count ||= {
      total: visible_recordings.size,
      new: visible_recordings.reject(&:viewed).size
    }
  end

  def page_views_count
    # Looks like [ ['/'], ['/', '/test'] ]
    recordings_pages = visible_recordings.map { |r| r.pages.map(&:url) }

    {
      total: recordings_pages.flatten.size,
      # This is unique per recording, not globally
      # unique, confusing
      unique: recordings_pages.map(&:uniq).size
    }
  end

  def self.find_by_external_id(site_id, id)
    find_by("site_id = ? AND external_attributes->>'id' = ?", site_id, id.to_s)
  end
end
