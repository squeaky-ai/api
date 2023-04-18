# typed: false
# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :recording
  belongs_to :user

  def session_id
    recording.session_id
  end
end
