# frozen_string_literal: true

class AddSiteLimitToPlan < ActiveRecord::Migration[7.0]
  def change
    change_table :plans do |t|
      t.integer :site_limit
    end
  end
end
