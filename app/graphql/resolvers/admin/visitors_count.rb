# frozen_string_literal: true

module Resolvers
  module Admin
    class VisitorsCount < Resolvers::Base
      type Integer, null: false

      def resolve
        Visitor.count
      end
    end
  end
end
