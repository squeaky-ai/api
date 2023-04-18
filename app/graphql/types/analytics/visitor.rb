# frozen_string_literal: true

module Types
  module Analytics
    class Visitor < Types::BaseObject
      graphql_name 'AnalyticsVisitor'

      field :date_key, String, null: false
      field :all_count, Integer, null: false
      field :new_count, Integer, null: false
      field :existing_count, Integer, null: false
    end
  end
end
