# frozen_string_literal: true

module Types
  module Recordings
    class Pagination < Types::BaseObject
      graphql_name 'RecordingsPagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Recordings::Sort, null: false
    end
  end
end
