# frozen_string_literal: true

class RenameParnerInvoicesColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :partner_invoices, :invoice_number, :filename
  end
end
