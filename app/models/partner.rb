# frozen_string_literal: true

class Partner < ApplicationRecord
  validates :slug, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  belongs_to :user

  has_many :referrals

  has_many :sites, through: :referrals
end
