# typed: false
# frozen_string_literal: true

class Referral < ApplicationRecord
  validates :url, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  belongs_to :partner, optional: true
  belongs_to :site, optional: true
end
