# frozen_string_literal: true

module Types
  module Common
    class Dates < Types::BaseObject
      graphql_name 'CommonDates'

      field :iso8601, String, null: false
      field :nice_date, String, null: false
      field :nice_date_time, String, null: false
      field :short_date, String, null: false
    end
  end
end
