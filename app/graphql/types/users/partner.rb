# frozen_string_literal: true

module Types
  module Users
    class Partner < Types::BaseObject
      graphql_name 'UsersPartner'

      field :name, String, null: false
      field :slug, String, null: false
    end
  end
end
