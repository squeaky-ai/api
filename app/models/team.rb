# frozen_string_literal: true

# A team belongs to a user, and also a site. There
# can be only one owner per site, but there can be
# multiple admins. Users can be invited and must
# accept the invite before they see anything
class Team < ApplicationRecord
  belongs_to :site
  belongs_to :user

  OWNER = 2
  ADMIN = 1
  MEMBER = 0

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
