# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :site
  belongs_to :user

  OWNER = 2
  ADMIN = 1
  MEMBER = 0

  REJECTED = 2
  PENDING = 1
  ACCEPTED = 0

  def owner?
    role == OWNER
  end

  def admin?
    role > MEMBER
  end

  def pending?
    status == PENDING
  end
end
