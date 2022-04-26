# frozen_string_literal: true

class AddAnonymiseFormToSite < ActiveRecord::Migration[7.0]
  def change
    change_table :sites do |t|
      t.boolean :anonymise_form_inputs, null: false, default: true
    end
  end
end
