# frozen_string_literal: true

class AddPlanIdUuid < ActiveRecord::Migration[7.0]
  def change
    change_table :plans do |t|
      t.string :plan_id
    end
  end
end
