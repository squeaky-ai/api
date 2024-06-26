# frozen_string_literal: true

module Resolvers
  module Sites
    class Feedback < Resolvers::Base
      type Types::Feedback::Feedback, null: false

      def resolve
        object.feedback || ::Feedback.create_with_defaults(object)
      end
    end
  end
end
