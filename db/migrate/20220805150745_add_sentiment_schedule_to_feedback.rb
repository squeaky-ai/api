# typed: false
# frozen_string_literal: true

class AddSentimentScheduleToFeedback < ActiveRecord::Migration[7.0]
  def change
    change_table :feedback do |t|
      t.string :sentiment_schedule
    end
  end
end
