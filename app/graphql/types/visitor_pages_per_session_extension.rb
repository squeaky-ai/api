# frozen_string_literal: true

module Types
  # Pages per session by a particular visitor
  class VisitorPagesPerSessionExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      visitor_id = object.object[:id]

      counts = Recording
               .where(visitor_id: visitor_id)
               .joins(:pages)
               .group(:id)
               .count(:pages)

      values = counts.values
      values.sum.fdiv(values.size)
    end
  end
end
