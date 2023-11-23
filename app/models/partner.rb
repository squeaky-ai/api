# frozen_string_literal: true

class Partner < ApplicationRecord
  validates :slug, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  belongs_to :user

  has_many :referrals
  has_many :partner_invoices

  has_many :sites, through: :referrals

  delegate :all_time_commission, to: :commission

  delegate :pay_outs, to: :commission

  def invoices
    partner_invoices
  end

  private

  def commission
    @commission ||= CommissionService.new(self)
  end
end
