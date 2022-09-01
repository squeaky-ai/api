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
  has_many :recordings
  has_many :notes, through: :recordings
  has_many :visitors, through: :recordings
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings
  has_many :tags
  has_many :clicks
  has_many :custom_events
  has_many :error_events
  has_many :event_captures, dependent: :destroy
  has_many :event_groups

  has_one :plan, dependent: :destroy
  has_one :billing, dependent: :destroy

  has_one :consent
  has_one :feedback

  # The plural sounds weird
  alias_attribute :team, :teams

  default_scope { order(name: :asc) }

  after_create { create_plan(tier: 0) }

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

  def recordings_count
    recordings.where(status: Recording::ACTIVE).count
  end

  def verified?
    !verified_at.nil?
  end

  def verify!
    return if verified_at

    Stats.count('site_verified')

    update!(verified_at: Time.now)
  end

  def unverify!
    update!(verified_at: nil)
  end

  def unlock_recordings!
    # Do not use .update as it instantiates the models
    # and will use a shit load of resources if there
    # are a lot of recordigns to unlock!
    recordings.where(status: Recording::LOCKED).update_all(status: Recording::ACTIVE)
  end

  def self.format_uri(url)
    uri = URI(url)
    return nil unless uri.scheme && uri.host

    "#{uri.scheme}://#{uri.host.downcase}"
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
