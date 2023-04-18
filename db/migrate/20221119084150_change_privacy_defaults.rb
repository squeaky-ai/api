# frozen_string_literal: true

class ChangePrivacyDefaults < ActiveRecord::Migration[7.0]
  def change
    change_column_default :sites, :anonymise_text, true
    change_column_default :sites, :anonymise_form_inputs, true
  end
end
