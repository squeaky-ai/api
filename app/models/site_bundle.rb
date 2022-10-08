# frozen_string_literal: true

class SiteBundle < ApplicationRecord
  has_many :site_bundles_sites, dependent: :destroy

  def plan
    primary_site.plan
  end

  def sites
    site_bundles_sites.map(&:site)
  end

  def primary_site
    site_bundles_sites.find(&:primary).site
  end
end
