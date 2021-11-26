# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetOne < Resolvers::Base
      type Types::Visitors::Visitor, null: true

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
