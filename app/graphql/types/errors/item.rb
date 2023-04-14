# typed: false
# frozen_string_literal: true

module Types
  module Errors
    class Item < Types::BaseObject
      graphql_name 'ErrorsItem'

      field :id, ID, null: false
      field :message, String, null: false
      field :error_count, Integer, null: false
      field :recording_count, Integer, null: false
      field :last_occurance, Types::Common::Dates, null: false

      def last_occurance
        DateFormatter.format(date: object['last_occurance'], timezone: context[:timezone])
      end
    end
  end
end
