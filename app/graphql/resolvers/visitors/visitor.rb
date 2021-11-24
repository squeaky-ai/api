# frozen_string_literal: true

module Resolvers
  module Visitors
    # Get a single visitor by their visitor_id
    class Visitor < Resolvers::Base
      type Integer, null: false

      argument :visitor_id, GraphQL::Types::ID, required: true

      def resolve(visitor_id:)
        Visitor
          .eager_load(:recordings, :pages)
          .where('recordings.site_id = ? AND visitors.id = ?', object.id, visitor_id)
          .first
      end
    end
  end
end
