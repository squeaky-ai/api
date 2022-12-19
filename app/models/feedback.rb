# frozen_string_literal: true

class Feedback < ApplicationRecord
  include ActiveModel::Serialization

  belongs_to :site

  self.table_name = 'feedback'

  def self.create_with_defaults(site)
    create(
      site_id: site.id,
      nps_enabled: false,
      nps_accent_color: '#0074E0',
      nps_schedule: 'once',
      nps_phrase: site.name,
      nps_follow_up_enabled: true,
      nps_contact_consent_enabled: false,
      nps_layout: 'full_width',
      nps_excluded_pages: [],
      nps_languages: ['en'],
      nps_languages_default: 'en',
      nps_hide_logo: false,
      sentiment_enabled: false,
      sentiment_accent_color: '#0074E0',
      sentiment_excluded_pages: [],
      sentiment_layout: 'right_middle',
      sentiment_devices: %w[desktop tablet],
      sentiment_hide_logo: false,
      sentiment_schedule: 'always',
      sentiment_languages: ['en'],
      sentiment_languages_default: 'en'
    )
  end
end
