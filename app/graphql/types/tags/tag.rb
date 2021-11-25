# frozen_string_literal: true

module Types
  module Tags
    class Tag < Types::BaseObject
      graphql_name 'Tag'

      field :id, ID, null: false
      field :name, String, null: false
      field :created_at, String, null: false
      field :updated_at, String, null: true
    end
  end
end
