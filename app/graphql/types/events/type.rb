# frozen_string_literal: true

module Types
  module Events
    class Type < Types::BaseEnum
      graphql_name 'EventsType'

      value 'capture', ''
      value 'group', ''
    end
  end
end
