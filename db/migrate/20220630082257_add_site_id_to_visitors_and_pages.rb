# frozen_string_literal: true

class AddSiteIdToVisitorsAndPages < ActiveRecord::Migration[7.0]
  def change
    change_table :visitors do |t|
      t.belongs_to :site
    end

    change_table :pages do |t|
      t.belongs_to :site
    end
  end
end
