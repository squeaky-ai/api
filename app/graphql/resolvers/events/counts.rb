# frozen_string_literal: true

module Resolvers
  module Events
    class Counts < Resolvers::Base
      type Types::Events::Counts, null: false

      argument :group_ids, [ID], required: true, default_value: []
      argument :capture_ids, [ID], required: true, default_value: []
      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve(group_ids:, capture_ids:, from_date:, to_date:)
        date_format, group_type, group_range = Charts.date_groups(from_date, to_date, clickhouse: true)

        puts '@@', group_ids, capture_ids, date_format

        {
          group_type:,
          group_range:,
          items: []
        }
      end
    end
  end
end
