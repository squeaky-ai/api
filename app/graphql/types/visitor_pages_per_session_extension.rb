# frozen_string_literal: true

module Types
  # Pages per session by a particular visitor
  class VisitorPagesPerSessionExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      visitor_id = object.object[:visitor_id]

      Recording
        .select('AVG( array_length(page_views, 1) ) pages_per_session')
        .where('visitor_id = ?', visitor_id)
        .to_a
        .first
        .pages_per_session
    end
  end
end
