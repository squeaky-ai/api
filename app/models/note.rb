# frozen_string_literal: true

# A list of notes that can be added to a recording
class Note < ApplicationRecord
  belongs_to :recording
  belongs_to :user

  def to_h
    {
      id: id,
      body: body,
      timestamp: timestamp,
      user: user.to_h,
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
