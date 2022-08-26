# frozen_string_literal: true

class Team < ApplicationRecord
  belongs_to :site
  belongs_to :user

  # Roles
  OWNER = 2
  ADMIN = 1
  MEMBER = 0
  READ_ONLY = -1

  # Statuses
  PENDING = 1
  ACCEPTED = 0

  def owner?
    role == OWNER
  end

  def admin?
    role == ADMIN
  end

  def member?
    role == MEMBER
  end

  def read_only?
    role == READ_ONLY
  end

  def pending?
    status == PENDING
  end

  def role_name
    case role
    when OWNER
      'Owner'
    when ADMIN
      'Admin'
    when MEMBER
      'User'
    when READ_ONLY
      'Read-only'
    end
  end
end
