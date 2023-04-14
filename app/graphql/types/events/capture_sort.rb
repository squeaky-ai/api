# typed: false
# frozen_string_literal: true

module Types
  module Events
    class CaptureSort < Types::BaseEnum
      graphql_name 'EventsCaptureSort'

      value 'name__asc', 'Alphabeticaly by name (A-Z)'
      value 'name__desc', 'Alphabeticaly by name (Z-A)'
      value 'count__asc', 'Number of triggered events ascending'
      value 'count__desc', 'Number of triggered events descending'
    end
  end
end
