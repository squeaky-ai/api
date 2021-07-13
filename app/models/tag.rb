# frozen_string_literal: true

# A list of tags that can be added to a recording
class Tag < ApplicationRecord
  belongs_to :recording

  def to_h
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
