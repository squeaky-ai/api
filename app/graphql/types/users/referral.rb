# typed: false
# frozen_string_literal: true

module Types
  module Users
    class Referral < Types::BaseObject
      graphql_name 'UsersReferral'

      field :id, ID, null: false
      field :url, String, null: false
      field :site, Types::Sites::Site, null: true
    end
  end
end
