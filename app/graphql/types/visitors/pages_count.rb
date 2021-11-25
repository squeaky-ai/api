# frozen_string_literal: true

module Types
  module Visitors
    class PagesCount < Types::BaseObject
      graphql_name 'VisitorsPagesCount'

      field :total, Integer, null: false
      field :unique, Integer, null: false
    end
  end
end
