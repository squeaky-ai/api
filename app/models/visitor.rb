# frozen_string_literal: true

class Visitor < ApplicationRecord
  has_many :recordings
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings

  WEB = 'web'
  API = 'api'

  # This allows us to set the recordings count externally,
  # like in visitiors/highlights.rb where we have fetched
  # the counts from ClickHouse
  attr_accessor :recording_count

  def linked_data
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def self.find_by_external_id(site_id, id)
    find_by("site_id = ? AND external_attributes->>'id' = ?", site_id, id.to_s)
  end

  def viewed
    viewed?
  end

  def viewed?
    recordings.filter(&:viewed).size.positive?
  end

  def first_viewed_at
    recordings.min_by(&:connected_at)&.connected_at
  end

  def last_activity_at
    recordings.max_by(&:disconnected_at)&.disconnected_at
  end

  def browsers
    recordings.filter(&:browser).map(&:browser)
  end

  def languages
    recordings.filter(&:language).map(&:language)
  end

  def country_codes
    recordings.map(&:country_code).compact.uniq
  end

  def destroy_all_recordings!
    recording_ids = recordings.pluck(:id)
    RecordingDeleteJob.perform_later(recording_ids) unless recording_ids.empty?
  end
end
