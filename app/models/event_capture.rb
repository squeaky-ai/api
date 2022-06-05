# frozen_string_literal: true

class EventCapture < ApplicationRecord
  belongs_to :site
  has_and_belongs_to_many :event_groups

  PAGE_VISIT = 0
  TEXT_CLICK = 1
  SELECTOR_CLICK = 2
  ERROR = 3
  CUSTOM = 4

  def type
    event_type
  end

  def group_names
    event_groups.map(&:name)
  end
end
