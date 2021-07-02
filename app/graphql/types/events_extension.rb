# frozen_string_literal: true

module Types
  # Fetch all of the events from Dynamo. The AWS::Record client
  # will automatically loop through the last_evaluated_key to
  # fetch all of the items.
  class EventsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      key = "#{object.object[:site_id]}_#{object.object[:id]}"

      query = Event
              .build_query
              .key_expr(':site_session_id = ?'.dup, key)
              .scan_ascending(true)
              .on_index(:timestamp)
              .complete!

      query.each
    end
  end
end
