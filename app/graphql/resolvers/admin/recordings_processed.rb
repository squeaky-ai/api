# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsProcessed < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        Sidekiq::Stats.new.processed || 0
      end
    end
  end
end
