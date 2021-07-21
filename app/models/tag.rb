# frozen_string_literal: true

# A list of tags that can be added to a recording
class Tag < ApplicationRecord
  belongs_to :recording
end
