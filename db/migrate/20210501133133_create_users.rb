# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email

      t.datetime :invited_at
      t.datetime :last_signed_in_at

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end
