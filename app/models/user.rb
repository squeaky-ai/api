# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are: :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :timeoutable,
         :lockable,
         :trackable,
         :invitable

  has_many :teams, dependent: :destroy
  has_many :sites, through: :teams
  has_many :billings, dependent: :destroy

  has_one :communication, dependent: :destroy
  has_one :partner, dependent: :destroy

  # In admin/users.rb we assign the visitor
  # based on linked data but only for Squeaky
  attr_accessor :visitor

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

  def role_for(site)
    site.team.find { |t| t.user.id == id }&.role
  end

  def invite_to_team!
    # This is a procted devise method but we want to call
    # it to bypass the default invite flow when the user
    # already has an account
    generate_invitation_token!
  end

  def pending_team_invitation?
    teams.where(status: Team::PENDING).size.positive?
  end

  def communication_enabled?(key)
    return true if communication.nil?

    communication[key]
  end

  def comms_email
    provider_comms_email.presence || email
  end

  def self.find_team_invitation(token)
    user = User.find_by_invitation_token(token, true)

    {
      email: user&.email,
      has_pending: user&.pending_team_invitation? || false
    }
  end
end
