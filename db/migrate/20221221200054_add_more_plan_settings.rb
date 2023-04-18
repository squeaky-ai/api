# frozen_string_literal: true

class AddMorePlanSettings < ActiveRecord::Migration[7.0]
  def change
    change_table :plans do |t|
      t.integer :team_member_limit
      t.string :features_enabled, array: true, default: []
    end
  end
end
