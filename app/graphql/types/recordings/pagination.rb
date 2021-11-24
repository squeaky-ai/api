# frozen_string_literal: true

module Types
  module Recordings
    class Pagination < Types::BaseObject
      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, RecordingSortType, null: false
    end
  end
end
