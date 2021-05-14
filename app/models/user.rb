# frozen_string_literal: true

# The main user model. Users do not have any permissions
# of their own, instead they are set on a per site basis
# as part of the team model
class User < ApplicationRecord
  has_many :teams
  has_many :sites, through: :teams

  def full_name
    return nil unless first_name && last_name

    "#{first_name} #{last_name}"
  end

  def owner_for?(site)
    return false unless site

    site.owner.user.id == id
  end

  def admin_for?(site)
    return false unless site

    site.admins.any? { |a| a.user.id == id }
  end

  def member_of?(site)
    return false unless site

    site.team.any? { |t| t.user.id == id }
  end
end
