# frozen_string_literal: true

module Mutations
  module Feedback
    class NpsCreate < BaseMutation
      null false

      graphql_name 'NpsCreate'

      argument :site_id, ID, required: true
      argument :visitor_id, String, required: true
      argument :session_id, String, required: true
      argument :score, Integer, required: true
      argument :comment, String, required: false
      argument :contact, Boolean, required: false
      argument :email, String, required: false

      type Types::Common::GenericSuccess

      def resolve_with_timings(site_id:, visitor_id:, session_id:, score:, comment:, contact:, email:) # rubocop:disable Metrics/ParameterLists
        # This is the same structure as regular
        # events that get pushed into the websocket
        # queue
        event = {
          key: 'nps',
          value: {
            type: 5,
            data: { score:, comment:, contact:, email: },
            timestamp: Time.now.to_i * 1000
          }
        }

        key = "events::#{site_id}::#{visitor_id}::#{session_id}"

        Cache.redis.lpush(key, event.to_json)

        { message: 'NPS score saved' }
      end
    end
  end
end
