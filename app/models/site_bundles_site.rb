# frozen_string_literal: true

class SiteBundlesSite < ApplicationRecord
  belongs_to :site
  belongs_to :site_bundle
end
