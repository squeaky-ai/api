# frozen_string_literal: true

class Partner < ApplicationRecord
  belongs_to :user

  has_many :referrals
end
