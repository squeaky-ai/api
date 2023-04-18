# typed: false
# frozen_string_literal: true

class AddUtmParametersToRecording < ActiveRecord::Migration[7.0]
  def change
    change_table :recordings do |t|
      t.string :utm_source
      t.string :utm_medium
      t.string :utm_campaign
      t.string :utm_content
      t.string :utm_term
    end
  end
end
