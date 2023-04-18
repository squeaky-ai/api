# typed: false
# frozen_string_literal: true

class Consent < ApplicationRecord
  belongs_to :site

  def self.create_with_defaults(site)
    create(
      site_id: site.id,
      name: site.name,
      privacy_policy_url: "#{site.url}/privacy",
      layout: 'bottom_left',
      consent_method: 'disabled',
      languages: ['en'],
      languages_default: 'en'
    )
  end
end
