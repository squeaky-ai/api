# frozen_string_literal: true

module Types
  # Average session duration by a particular visitor
  class VisitorAverageSessionDurationExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      visitor_id = object.object[:visitor_id]

      Recording
        .select('AVG( (disconnected_at - connected_at) ) average_session_duration')
        .where('visitor_id = ?', visitor_id)
        .to_a
        .first
        .average_session_duration
    end
  end
end
