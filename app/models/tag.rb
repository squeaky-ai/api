# frozen_string_literal: true

# A list of tags that can be added to a recording
class Tag < ApplicationRecord
  has_and_belongs_to_many :recordings
end
