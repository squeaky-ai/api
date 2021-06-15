# frozen_string_literal: true

# The main user model. Users do not have any permissions
# of their own, instead they are set on a per site basis
# as part of the team model
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

  def serialize
    {
      'id' => id,
      'firstName' => first_name,
      'lastName' => last_name,
      'email' => email,
      'lastSignedInAt' => last_signed_in_at,
      'createdAt' => created_at,
      'updatedAt' => updated_at
    }
  end
end
