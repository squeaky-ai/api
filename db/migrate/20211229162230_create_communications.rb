# typed: false
# frozen_string_literal: true

class CreateCommunications < ActiveRecord::Migration[6.1]
  def change
    create_table :communications do |t|
      t.boolean :onboarding_email, null: false
      t.boolean :weekly_review_email, null: false
      t.boolean :monthly_review_email, null: false
      t.boolean :product_updates_email, null: false
      t.boolean :marketing_and_special_offers_email, null: false
      t.boolean :knowledge_sharing_email, null: false

      t.belongs_to :user

      t.timestamps
    end
  end
end
