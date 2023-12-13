# frozen_string_literal: true

class PartnerInvoice < ApplicationRecord
  belongs_to :partner

  PENDING = 0
  PAID = 1

  def invoice_url
    "#{Rails.application.config.api_host}/api/invoices/#{id}"
  end
end
