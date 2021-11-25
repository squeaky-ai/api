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

  # The plural sounds weird
  alias_attribute :team, :teams
  alias_attribute :team_size_exceeded, :team_size_exceeded?

  default_scope { order(name: :asc) }

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

  def recordings_count
    recordings.where(deleted: false).count
  end

  def verify!
    update!(verified_at: Time.now)
  end

  def unverify!
    update!(verified_at: nil)
  end

  def self.format_uri(url)
    uri = URI(url)
    return nil unless uri.scheme && uri.host

    "#{uri.scheme}://#{uri.host.downcase}"
  end

  def analytics(args)
    # This is a pure hack to get around having an extension
    # that only has extensions. The analytics extension does
    # not resolve anything of it's own
    { site_id: id, **args }
  end

  def nps(args)
    # This is a pure hack to get around having an extension
    # that only has extensions. The nps extension does not
    # resolve anything of it's own
    { site_id: id, **args }
  end

  def sentiment(args)
    # This is a pure hack to get around having an extension
    # that only has extensions. The sentiment extension does
    # not resolve anything of it's own
    { site_id: id, **args }
  end

  def team_size_exceeded?
    team.size >= Plan.new(plan).max_team_members
  end

  def recording_count_exceeded?
    count = recordings
            .where('deleted = false AND created_at > ? AND created_at < ?', Time.now.beginning_of_month, Time.now.end_of_month)
            .count
    count >= Plan.new(plan).max_monthly_recordings
  end

  def page_urls
    pages.select(:url).all.map(&:url).uniq
  end
end
