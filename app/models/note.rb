# frozen_string_literal: true

# A list of notes that can be added to a recording
class Note < ApplicationRecord
  belongs_to :recording
  belongs_to :user
end
