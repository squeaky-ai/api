# frozen_string_literal: true

class AddLogoHidingToFeedback < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.boolean :nps_hide_logo, null: false, default: false
      t.boolean :sentiment_hide_logo, null: false, default: false
    end
  end
end
