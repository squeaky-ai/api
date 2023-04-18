# frozen_string_literal: true

class CreateVisitors < ActiveRecord::Migration[6.1]
  def change
    create_table :visitors do |t|
      t.string :visitor_id, null: false
      t.boolean :starred, null: true, default: false
      t.string :external_id, null: true

      t.timestamps
    end

    change_table :recordings do |t|
      t.belongs_to :visitor
    end

    add_index :visitors, :visitor_id, unique: true
    remove_column :recordings, :viewer_id
  end
end
