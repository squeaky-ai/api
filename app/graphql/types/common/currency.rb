# typed: false
# frozen_string_literal: true

module Types
  module Common
    class Currency < Types::BaseEnum
      graphql_name 'Currency'

      value 'GBP'
      value 'EUR'
      value 'USD'
    end
  end
end
