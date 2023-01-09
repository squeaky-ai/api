class RemoveTierColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :plans, :tier
    change_column_null :plans, :plan_id, false
  end
end
