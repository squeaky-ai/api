# frozen_string_literal: true

module Types
  module Common
    class GenericSuccess < Types::BaseObject
      graphql_name 'FiltersSuccess'

      field :message, String, null: false
    end
  end
end
