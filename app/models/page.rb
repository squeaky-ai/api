# frozen_string_literal: true

# Page views for a recording
class Page < ApplicationRecord
  belongs_to :recording

  has_many :visitors, through: :recordings
end
