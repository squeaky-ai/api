# frozen_string_literal: true

class CreatePartnerInvoices < ActiveRecord::Migration[7.0]
  def change
    create_table :partner_invoices do |t|
      t.string :invoice_number, null: false
      t.integer :status, null: false
      t.date :issued_at
      t.date :due_at
      t.date :paid_at
      t.integer :amount, null: false
      t.currency :string, null: false

      t.belongs_to :partner
 
      t.timestamps
    end
  end
end
