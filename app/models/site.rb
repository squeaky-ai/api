# frozen_string_literal: true

class Site < ApplicationRecord
  validates :url, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  # Generate a uuid for the site when it's created
  # that will be used publicly
  attribute :uuid, :string, default: -> { SecureRandom.uuid }

  has_many :teams, dependent: :destroy
  has_many :users, through: :teams
  has_many :recordings
  has_many :notes, through: :recordings
  has_many :visitors
  has_many :pages, through: :recordings
  has_many :nps, through: :recordings
  has_many :sentiments, through: :recordings
  has_many :tags
  has_many :event_captures, dependent: :destroy
  has_many :event_groups

  has_one :plan, dependent: :destroy
  has_one :billing, dependent: :destroy

  has_one :site_bundles_site
  has_one :site_bundle, through: :site_bundles_site

  has_one :consent
  has_one :feedback
  has_one :provider_auth, dependent: :destroy

  # The plural sounds weird
  alias_attribute :team, :teams
  alias_attribute :bundled, :bundled?

  default_scope { order(name: :asc) }

  after_create { create_plan(plan_id: Plans.free_plan[:id]) }

  WEB_APP = 0
  WEBSITE = 1

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

  def bundled?
    !site_bundles_site.nil?
  end

  def bundled_with
    site_bundle&.sites || []
  end

  def magic_erasure_enabled_for_user?(current_user)
    return false unless [Team::OWNER, Team::ADMIN].include?(current_user&.role_for(self))

    magic_erasure_enabled
  end

  def destroy_all_recordings!
    # This will enqueue all recordings and it's associated
    # data to be deleted asynchronously
    ids = recordings.select(:id).map(&:id)
    RecordingDeleteJob.perform_later(ids)
  end

  def tracking_code
    <<~HTML
      <!-- Squeaky Tracking Code for #{url} -->
      <script>
        (function(s,q,u,e,a,k,y){s._sqSettings={site_id:'#{uuid}'};
          e=q.getElementsByTagName('head')[0];
          a=q.createElement('script');
          a.src=u+s._sqSettings.site_id;
          e.appendChild(a);
        })(window,document,'https://cdn.squeaky.ai/g/1.0.0/script.js?');
      </script>
    HTML
  end

  def self.find_by_api_key(api_key)
    find_by(api_key:)
  end
end
