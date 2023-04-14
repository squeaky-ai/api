# typed: false
# frozen_string_literal: true

class CreatePlan < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.integer :tier, null: false
      t.integer :max_monthly_recordings
      t.integer :data_storage_months
      t.integer :response_time_hours
      t.string :support, null: false, array: true, default: []
      t.boolean :sso_enabled, null: false, default: false
      t.boolean :audit_trail_enabled, null: false, default: false
      t.boolean :private_instance_enabled, null: false, default: false
      t.string :notes

      t.belongs_to :site

      t.timestamps
    end

    remove_column :sites, :plan
  end
end
