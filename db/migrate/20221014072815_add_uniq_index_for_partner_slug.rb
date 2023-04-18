# frozen_string_literal: true

class AddUniqIndexForPartnerSlug < ActiveRecord::Migration[7.0]
  def change
    add_index :partners, :slug, unique: true
  end
end
