class CreateChangelog < ActiveRecord::Migration[7.0]
  def change
    create_table :changelog do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.boolean :draft, null: false, default: true
      t.string :meta_image, null: false
      t.string :meta_description, null: false
      t.string :slug, null: false
      t.string :body, null: false

      t.timestamps
    end
  end
end
