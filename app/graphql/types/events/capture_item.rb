# typed: false
# frozen_string_literal: true

module Types
  module Events
    class CaptureItem < Types::BaseObject
      graphql_name 'EventsCaptureItem'

      field :id, ID, null: false
      field :name, String, null: false
      field :name_alias, String, null: true
      field :type, Integer, null: false
      field :rules, [Events::Rule, { null: false }], null: false
      field :count, Integer, null: false
      field :group_ids, [String, { null: false }], null: false
      field :group_names, [String, { null: false }], null: false
      field :source, String, null: true
      field :last_counted_at, Types::Common::Dates, null: true

      def last_counted_at
        DateFormatter.format(date: object.last_counted_at, timezone: context[:timezone])
      end
    end
  end
end
