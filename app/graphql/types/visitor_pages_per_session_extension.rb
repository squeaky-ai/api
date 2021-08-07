# frozen_string_literal: true

module Types
  # Pages per session by a particular visitor
  class VisitorPagesPerSessionExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      viewer_id = object.object[:viewer_id]

      Recording
        .select('AVG( array_length(page_views, 1) ) pages_per_session')
        .where('viewer_id = ?', viewer_id)
        .to_a
        .first
        .pages_per_session
    end
  end
end
