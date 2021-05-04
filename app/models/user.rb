# frozen_string_literal: true

class User < ApplicationRecord
  has_many :teams
  has_many :sites, through: :teams

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def admin_for?(site)
    site.admins.find { |a| a.user.id == id }
  end

  def member_of?(site)
    site.team.any? { |t| t.user.id == id }
  end
end
