# frozen_string_literal: true

module Types
  module Admin
    class Verified < Types::BaseObject
      graphql_name 'AdminVerified'

      field :verified, Float, null: false
      field :unverified, Float, null: false
    end
  end
end
