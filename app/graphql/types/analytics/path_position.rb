# frozen_string_literal: true

module Types
  module Analytics
    class PathPosition < Types::BaseEnum
      graphql_name 'PathPosition'

      value 'Start'
      value 'End'
    end
  end
end
