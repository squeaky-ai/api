# frozen_string_literal: true

class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.integer :amount, null: false
      t.string :currency, null: false
      t.string :invoice_web_url, null: false
      t.string :invoice_pdf_url, null: false
      t.string :interval, null: false
      t.string :pricing_id, null: false
      t.bigint :period_from, null: false
      t.bigint :period_to, null: false

      t.belongs_to :billing

      t.timestamps
    end
  end
end
