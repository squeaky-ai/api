# frozen_string_literal: true

class AddIndexForSomeTimestamps < ActiveRecord::Migration[7.0]
  def change
    add_index :recordings, :disconnected_at
    add_index :pages, :exited_at
  end
end
