# frozen_string_literal: true

class ChangeSite < ActiveRecord::Migration[6.1]
  def change
    change_table :sites do |t|
      t.datetime :checklist_dismissed_at
    end

    change_table :users do |t|
      # These are handled by Devise now
      t.remove :last_signed_in_at, :invited_at
    end
  end
end
