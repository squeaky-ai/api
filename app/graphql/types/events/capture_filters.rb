# frozen_string_literal: true

module Types
  module Events
    class CaptureFilters < BaseInputObject
      graphql_name 'EventsCaptureFilters'

      argument :source, String, required: false, default_value: nil
      argument :event_type, [Integer, { null: false }], required: false, default_value: []
    end
  end
end
