# frozen_string_literal: true

require 'time'

module Types
  class RecordingExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:query, String, required: false, description: 'Search for specific data')
      field.argument(:first, Integer, required: false, default_value: 10, description: 'The number of results to return')
      field.argument(:cursor, String, required: false, description: 'The cursor to fetch the next set of results')
    end

    def resolve(object:, arguments:, **_rest)
      query = Recording
              .build_query.key_expr(':site_id = ?'.dup, object.object.uuid)
              .scan_ascending(false)
              .limit(arguments[:first])
              .exclusive_start_key(arguments[:cursor])
              .complete!

      # query.last_evaluated_key

      query.page.map(&:serialize)
    end
  end
end
