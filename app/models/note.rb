# frozen_string_literal: true

class Note < ApplicationRecord
  belongs_to :recording
  belongs_to :user

  delegate :session_id, to: :recording
end
