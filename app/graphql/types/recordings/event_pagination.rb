# frozen_string_literal: true

module Types
  module Recordings
    class EventPagination < Types::BaseObject
      graphql_name 'RecordingsEventPagination'

      field :per_page, Integer, null: false
      field :item_count, Integer, null: false
      field :current_page, Integer, null: false
      field :total_pages, Integer, null: false
    end
  end
end
