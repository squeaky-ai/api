# typed: false
# frozen_string_literal: true

class AddFeedbackEmailPreference < ActiveRecord::Migration[7.0]
  def change
    change_table :communications do |t|
      t.boolean :feedback_email, null: false, default: true
    end
  end
end
