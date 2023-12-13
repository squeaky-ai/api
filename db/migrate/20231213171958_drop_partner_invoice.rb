# frozen_string_literal: true

class DropPartnerInvoice < ActiveRecord::Migration[7.1]
  def change
    drop_table :partner_invoices
  end
end
