# frozen_string_literal: true

class Visitor < ApplicationRecord
  has_many :recordings, dependent: :destroy
  has_many :pages, through: :recordings

  alias_attribute :viewed, :viewed?

  def locale
    recordings.first.locale
  end

  def language
    Locale.get_language(locale)
  end

  def devices
    recordings.map(&:device)
  end

  def attributes
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def viewed?
    visible_recordings.filter(&:viewed).size.positive?
  end

  def first_viewed_at
    first_event = recordings.min_by(&:connected_at)
    Time.at(first_event.connected_at / 1000).utc.iso8601
  end

  def last_activity_at
    last_event = recordings.max_by(&:disconnected_at)
    Time.at(last_event.disconnected_at / 1000).utc.iso8601
  end

  def visible_recordings
    @visible_recordings ||= recordings.reject(&:deleted)
  end

  def recordings_count
    {
      total: visible_recordings.size,
      new: visible_recordings.reject(&:viewed).size
    }
  end

  def page_views_count
    {
      total: pages.size,
      unique: visible_recordings.map(&:pages).uniq.size
    }
  end
end
