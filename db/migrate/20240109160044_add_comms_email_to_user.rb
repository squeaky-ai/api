# frozen_string_literal: true

class AddCommsEmailToUser < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :provider_comms_email
    end
  end
end
