# frozen_string_literal: true

require 'uri'
require 'securerandom'

# The main site model. The only unique constraint is the
# url as we can't have people having multiple sites
class Site < ApplicationRecord
  validates :url, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  # Generate a uuid for the site when it's created
  # that will be used publicly
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  has_many :teams, dependent: :destroy
  has_many :users, through: :teams

  # The plural sounds weird
  alias_attribute :team, :teams

  ESSENTIALS = 0
  PREMIUM = 1
  UNLIMITED = 2

  def owner
    team.find(&:owner?)
  end

  def owner_name
    owner.user.full_name
  end

  def admins
    team.filter(&:admin?)
  end

  def member(id)
    team.find { |t| t.id == id.to_i }
  end

  def plan_name
    case plan
    when ESSENTIALS
      I18n.t 'site.plan.essentials'
    when PREMIUM
      I18n.t 'site.plan.premium'
    when UNLIMITED
      I18n.t 'site.plan.unlimited'
    end
  end

  def create_authorizer!
    authorizer = Authorizer.new(site_id: uuid, active: true, origin: url)
    authorizer.save!
    authorizer
  end

  def delete_authorizer!
    authorizer = Authorizer.find(site_id: uuid)
    authorizer&.delete!
    nil
  end

  def verify!
    update!(verified_at: Time.now)
  end

  def days_since_last_recording
    -1
  end

  def self.format_uri(url)
    uri = URI(url)
    return nil unless uri.scheme && uri.host

    "#{uri.scheme}://#{uri.host.downcase}"
  end
end
