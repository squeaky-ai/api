# frozen_string_literal: true

module Resolvers
  module Admin
    class ActiveVisitors < Resolvers::Base
      type [Types::Admin::ActiveVisitorCount, { null: false }], null: false

      def resolve
        items = Cache.redis.zrange('active_user_count', 0, -1, with_scores: true)

        items.map do |slice|
          {
            site_id: slice[0],
            count: slice[1]
          }
        end
      end
    end
  end
end
