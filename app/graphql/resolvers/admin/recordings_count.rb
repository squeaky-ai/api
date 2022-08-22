# frozen_string_literal: true

module Resolvers
  module Admin
    class RecordingsCount < Resolvers::Base
      type Integer, null: false

      def resolve_with_timings
        Rails.cache.fetch('data_cache:AdminRecordingsCount', expires_in: 1.hour) do
          Recording.all.count
        end
      end
    end
  end
end
