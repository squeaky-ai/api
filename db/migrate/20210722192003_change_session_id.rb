# frozen_string_literal: true

class ChangeSessionId < ActiveRecord::Migration[6.1]
  def change
    add_index :recordings, :session_id, unique: true
  end
end
