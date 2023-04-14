# typed: false
# frozen_string_literal: true

class AddPages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :url, null: false
      t.bigint :entered_at, null: false
      t.bigint :exited_at, null: false

      t.belongs_to :recording

      t.timestamps
    end

    remove_column :sites, :avatar
    remove_column :sites, :checklist_dismissed_at
  end
end
