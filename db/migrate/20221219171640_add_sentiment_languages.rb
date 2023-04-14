# typed: false
# frozen_string_literal: true

class AddSentimentLanguages < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.string :sentiment_languages, array: true, default: [], null: false
      t.string :sentiment_languages_default
    end
  end
end
