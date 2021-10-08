# frozen_string_literal: true

class CreateRecordingsTagsJoinTable < ActiveRecord::Migration[6.1]
  create_join_table :recordings, :tags

  change_table :tags do |t|
   t.belongs_to :site
  end

  remove_column :tags, :recording_id
end
