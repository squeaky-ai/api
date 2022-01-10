# frozen_string_literal: true

module Resolvers
  module Sites
    class Plan < Resolvers::Base
      type Types::Sites::Plan, null: false

      def resolve
        recordings_limit = ::Plan.new(object.plan).max_monthly_recordings
        recordings_locked = recordings_locked_count

        {
          type: object.plan,
          name: object.plan_name,
          exceeded: recordings_locked.positive?,
          recordings_limit:,
          recordings_locked:,
          visitors_locked: visitors_locked_count
        }
      end

      private

      def recordings_locked_count
        object.recordings
              .where(
                'status = ? AND created_at > ? AND created_at < ?',
                Recording::LOCKED,
                Time.now.beginning_of_month,
                Time.now.end_of_month
              )
              .count
      end

      def visitors_locked_count
        object.visitors
              .joins(:recordings)
              .preload(:recordings)
              .where(
                'recordings.status = ? AND visitors.created_at > ? AND visitors.created_at < ?',
                Recording::LOCKED,
                Time.now.beginning_of_month,
                Time.now.end_of_month
              )
              .count
      end
    end
  end
end
