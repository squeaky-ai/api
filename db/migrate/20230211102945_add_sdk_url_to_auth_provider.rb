# frozen_string_literal: true

class AddSdkUrlToAuthProvider < ActiveRecord::Migration[7.0]
  def change
    change_table :provider_auth do |t|
      t.string :sdk_url
    end
  end
end
