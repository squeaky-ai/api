# frozen_string_literal: true

module Resolvers
  module Recordings
    class Visitor < Resolvers::Base
      type 'Types::Visitors::Visitor', null: true

      def resolve
        VisitorService.new.find_by_id(site_id: object.site_id, visitor_id: object.visitor_id)
      end
    end
  end
end
