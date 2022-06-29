# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        Recording.all.count
      end
    end
  end
end
