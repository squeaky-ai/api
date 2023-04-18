# frozen_string_literal: true

module Types
  module Tags
    class Tag < Types::BaseObject
      graphql_name 'Tag'

      field :id, ID, null: false
      field :name, String, null: false
    end
  end
end
