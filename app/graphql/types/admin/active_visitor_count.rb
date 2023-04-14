# typed: false
# frozen_string_literal: true

module Types
  module Admin
    class ActiveVisitorCount < Types::BaseObject
      graphql_name 'ActiveVisitorCount'

      field :site_id, ID, null: false
      field :count, Integer, null: false
    end
  end
end
