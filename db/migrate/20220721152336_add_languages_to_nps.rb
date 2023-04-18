# typed: false
# frozen_string_literal: true

class AddLanguagesToNps < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.string :nps_languages, array: true, default: [], null: false
      t.string :nps_languages_default
    end
  end
end
