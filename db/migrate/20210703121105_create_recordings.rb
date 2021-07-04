class CreateRecordings < ActiveRecord::Migration[6.1]
  def change
    create_table :recordings do |t|
      t.string :session_id, null: false
      t.string :viewer_id, null: false
      t.string :locale, null: false
      t.string :page_views, null: false, array: true, default: []
      t.string :useragent, null: false
      t.integer :viewport_x, null: false
      t.integer :viewport_y, null: false
      t.datetime :connected_at, null: false
      t.datetime :disconnected_at, null: false

      t.belongs_to :site

      t.timestamps
    end
  end
end
