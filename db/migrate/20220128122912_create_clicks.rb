# frozen_string_literal: true

class CreateClicks < ActiveRecord::Migration[7.0]
  def change
    create_view :clicks, materialized: true
  end
end
