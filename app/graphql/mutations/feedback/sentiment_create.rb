# frozen_string_literal: true

module Mutations
  module Feedback
    class SentimentCreate < BaseMutation
      null false

      graphql_name 'SentimentCreate'

      argument :site_id, ID, required: true
      argument :visitor_id, String, required: true
      argument :session_id, String, required: true
      argument :score, Integer, required: true
      argument :comment, String, required: false

      type Types::Common::GenericSuccess

      def resolve_with_timings(site_id:, visitor_id:, session_id:, score:, comment:)
        # This is the same structure as regular
        # events that get pushed into the websocket
        # queue
        event = {
          key: 'sentiment',
          value: {
            type: 5,
            data: { score:, comment: },
            timestamp: Time.now.to_i * 1000
          }
        }

        key = "events::#{site_id}::#{visitor_id}::#{session_id}"

        Cache.redis.lpush(key, event.to_json)

        { message: 'Sentiment score saved' }
      end
    end
  end
end
