# frozen_string_literal: true

class Visitor < ApplicationRecord
  has_many :recordings, dependent: :destroy
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings

  WEB = 'web'
  API = 'api'

  # This allows us to set the recordings count externally,
  # like in visitiors/highlights.rb where we have fetched
  # the counts from ClickHouse
  attr_writer :recording_count

  def linked_data
    return nil if external_attributes.empty?

    external_attributes.to_json
  end

  def self.find_by_external_id(site_id, id)
    find_by("site_id = ? AND external_attributes->>'id' = ?", site_id, id.to_s)
  end
end
