# typed: false
# frozen_string_literal: true

class EventCapture < ApplicationRecord
  belongs_to :site
  has_and_belongs_to_many :event_groups

  validates :name, uniqueness: { scope: :site_id }

  PAGE_VISIT = 0
  TEXT_CLICK = 1
  SELECTOR_CLICK = 2
  ERROR = 3
  CUSTOM = 4
  UTM_PARAMETERS = 5

  WEB = 'web'
  API = 'api'

  def type
    event_type
  end

  def group_names
    event_groups.map(&:name)
  end

  def group_ids
    event_groups.map(&:id)
  end

  def self.create_names_for_site!(site, names, source)
    names.each do |name|
      create(
        name:,
        rules: [{ matcher: 'equals', condition: 'or', value: name }],
        event_type: EventCapture::CUSTOM,
        site:,
        source:,
        event_groups: []
      )
    end
  end
end
