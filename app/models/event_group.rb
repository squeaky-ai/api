# frozen_string_literal: true

class EventGroup < ApplicationRecord
  belongs_to :site
  has_and_belongs_to_many :event_captures
end
