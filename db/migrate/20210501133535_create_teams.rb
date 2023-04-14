# typed: false
# frozen_string_literal: true

class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams do |t|
      t.integer :status
      t.integer :role

      t.belongs_to :user
      t.belongs_to :site

      t.timestamps
    end
  end
end
