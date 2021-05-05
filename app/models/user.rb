# frozen_string_literal: true

class User < ApplicationRecord
  has_many :teams
  has_many :sites, through: :teams

  def full_name
    return nil unless first_name && last_name

    "#{first_name} #{last_name}"
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
