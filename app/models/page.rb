# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :recording

  has_many :visitors, through: :recordings
end
