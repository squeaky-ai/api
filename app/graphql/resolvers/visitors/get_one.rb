# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetOne < Resolvers::Base
      type 'Types::Visitors::Visitor', null: true

      argument :visitor_id, GraphQL::Types::ID, required: true

      def resolve(visitor_id:)
        VisitorService.new.find_by_id(site_id: object.id, visitor_id:)
      end
    end
  end
end
