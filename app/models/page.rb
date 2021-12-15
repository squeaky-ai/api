# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :recording, counter_cache: true

  has_many :visitors, through: :recordings
end
