# frozen_string_literal: true

module Types
  module Events
    class HistoryType < Types::BaseEnum
      graphql_name 'EventsHistoryType'

      value 'capture', ''
      value 'group', ''
    end
  end
end
