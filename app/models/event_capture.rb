# frozen_string_literal: true

class EventCapture < ApplicationRecord
  has_and_belongs_to_many :event_groups
end
