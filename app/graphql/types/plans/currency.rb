# frozen_string_literal: true

module Types
  module Plans
    class Currency < Types::BaseEnum
      graphql_name 'PlansCurrency'

      value 'GBP'
      value 'EUR'
      value 'USD'
    end
  end
end
