# typed: false
# frozen_string_literal: true

class Page < ApplicationRecord
  belongs_to :recording, counter_cache: true

  has_many :visitors, through: :recordings

  def entered_at
    Time.at(self[:entered_at] / 1000).utc
  end

  def exited_at
    Time.at(self[:exited_at] / 1000).utc
  end
end
