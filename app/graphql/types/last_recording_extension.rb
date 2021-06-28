# frozen_string_literal: true

require 'date'

module Types
  # Query Dynamo with the LSI to get the timestamp so that
  # we can return how many days it's been since the last
  # recording was stored.
  class LastRecordingExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      last_recording = Recording.query(
        key_condition_expression: 'site_id = :site_id',
        expression_attribute_values: { ':site_id': object.object[:uuid] },
        limit: 1,
        index_name: 'last_updated_at',
        scan_index_forward: false
      )

      return -1 if last_recording.empty?

      date = Time.at(last_recording.page.first.disconnected_at / 1000).to_datetime
      (DateTime.now - date).to_i
    end
  end
end
