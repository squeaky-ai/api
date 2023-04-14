# typed: false
# frozen_string_literal: true

class CreateDataExports < ActiveRecord::Migration[7.0]
  def change
    create_table :data_exports do |t|
      t.string :filename, null: false
      t.integer :export_type, null: false

      t.bigint :exported_at, null: true

      t.string :start_date, null: false
      t.string :end_date, null: false

      t.belongs_to :site

      t.timestamps
    end
  end
end
