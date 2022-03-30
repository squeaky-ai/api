# frozen_string_literal: true

require 'uri'
require 'securerandom'

class Site < ApplicationRecord
  validates :url, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  # Generate a uuid for the site when it's created
  # that will be used publicly
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :recordings, dependent: :destroy
  has_many :notes, through: :recordings
  has_many :visitors, through: :recordings
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings
  has_many :tags

  has_one :feedback
  has_one :billing, dependent: :destroy

  # The plural sounds weird
  alias_attribute :team, :teams

  default_scope { order(name: :asc) }

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
    Plan.new(plan).name
  end

  def recordings_count
    recordings.where(status: Recording::ACTIVE).count
  end

  def verify!
    update!(verified_at: Time.now)
  end

  def unverify!
    update!(verified_at: nil)
  end

  def unlock_recordings!
    recordings.where(status: Recording::LOCKED).update(status: Recording::ACTIVE)
  end

  def self.format_uri(url)
    uri = URI(url)
    return nil unless uri.scheme && uri.host

    "#{uri.scheme}://#{uri.host.downcase}"
  end

  def recording_count_exceeded?
    count = recordings
            .where('status = ? AND created_at > ? AND created_at < ?', Recording::ACTIVE, Time.now.beginning_of_month, Time.now.end_of_month)
            .count
    count >= Plan.new(plan).max_monthly_recordings
  end

  def valid_billing?
    # If they are on the free plan then we don't care
    return true if plan.zero?

    # There are some people that are on paid tiers from
    # when Squeaky was in beta. They don't have any
    # billing
    return true if billing.nil?

    billing&.status == Billing::VALID
  end

  def page_urls
    pages.select(:url).all.map(&:url).uniq
  end

  def active_user_count
    count = Cache.redis.zscore('active_user_count', uuid)
    count.to_i
  end

  def nps_enabled?
    feedback&.nps_enabled || false
  end

  def sentiment_enabled?
    feedback&.sentiment_enabled || false
  end
end
