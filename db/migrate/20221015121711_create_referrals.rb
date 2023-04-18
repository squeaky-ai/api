# frozen_string_literal: true

class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referrals do |t|
      t.string :url

      t.belongs_to :partner
      t.belongs_to :site

      t.timestamps
    end

    add_index :referrals, :url, unique: true
  end
end
