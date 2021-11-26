# frozen_string_literal: true

module Types
  module Common
    class FiltersDate < BaseInputObject
      graphql_name 'FiltersDate'

      argument :range_type, Types::Common::FiltersRange, required: false
      argument :from_type, Types::Common::FiltersStart, required: false
      argument :from_date, String, required: false
      argument :between_from_date, String, required: false
      argument :between_to_date, String, required: false
    end
  end
end
