# frozen_string_literal: true

class EventGroup < ApplicationRecord
  has_and_belongs_to_many :event_captures
end
