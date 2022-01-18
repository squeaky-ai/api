# frozen_string_literal: true

module Types
  module Recordings
    class Country < Types::BaseObject
      graphql_name 'RecordingsCountry'

      field :code, String, null: false
      field :name, String, null: false
      field :count, Integer, null: false
    end
  end
end
