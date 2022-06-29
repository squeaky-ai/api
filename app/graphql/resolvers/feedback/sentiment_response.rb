# frozen_string_literal: true

module Resolvers
  module Feedback
    class SentimentResponse < Resolvers::Base
      type Types::Feedback::SentimentResponse, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Feedback::SentimentResponseSort, required: false, default_value: 'timestamp__desc'

      def resolve_with_timings(page:, size:, sort:)
        results = Sentiment
                  .joins(recording: :visitor)
                  .where(
                    'recordings.site_id = ? AND
                     sentiments.created_at::date >= ? AND
                     sentiments.created_at::date <= ? AND
                     recordings.status IN (?)',
                    object[:site_id],
                    object[:from_date],
                    object[:to_date],
                    [Recording::ACTIVE, Recording::DELETED]
                  )
                  .select('
                    sentiments.*,
                    recordings.session_id,
                    recordings.viewport_x,
                    recordings.viewport_y,
                    recordings.device_x,
                    recordings.device_y,
                    recordings.useragent,
                    visitors.id visitor_id,
                    visitors.visitor_id visitor_visitor_id
                  ')
                  .order(sort_by(sort))
                  .page(page)
                  .per(size)

        {
          items: map_results(results),
          pagination: {
            page_size: size,
            total: results.total_count,
            sort:
          }
        }
      end

      private

      def sort_by(sort)
        case sort
        when 'timestamp__desc'
          'created_at DESC'
        when 'timestamp__asc'
          'created_at ASC'
        end
      end

      def map_results(results)
        results.map do |r|
          useragent = UserAgent.parse(r.useragent)

          {
            id: r.id,
            score: r.score,
            comment: r.comment,
            session_id: r.session_id,
            recording_id: r.recording_id,
            timestamp: r.created_at.utc,
            visitor: {
              id: r.visitor_id,
              visitor_id: r.visitor_visitor_id
            },
            device: {
              browser_name: useragent.browser,
              browser_details: "#{useragent.browser} Version #{useragent.version}",
              viewport_x: r.viewport_x,
              viewport_y: r.viewport_y,
              device_x: r.device_x,
              device_y: r.device_y,
              device_type: useragent.mobile? ? 'Mobile' : 'Computer',
              useragent: r.useragent
            }
          }
        end
      end
    end
  end
end
