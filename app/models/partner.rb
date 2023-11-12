# frozen_string_literal: true

class Partner < ApplicationRecord
  validates :slug, uniqueness: { message: I18n.t('site.validation.site_in_use') }

  belongs_to :user

  has_many :referrals
  has_many :partner_invoices

  has_many :sites, through: :referrals

  def all_time_commission
    commission.all_time_commission
  end

  def pay_outs
    commission.pay_outs
  end

  def invoices
    partner_invoices
  end

  private

  def commission
    @commission ||= CommissionService.new(self)
  end
end
