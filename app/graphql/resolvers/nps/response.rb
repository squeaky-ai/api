# frozen_string_literal: true

module Resolvers
  module Nps
    class Response < Resolvers::Base
      type Types::Nps::Response, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Nps::ResponseSort, required: false, default_value: 'timestamp__desc'

      def resolve(page:, size:, sort:)
        results = Nps
                  .joins(recording: :visitor)
                  .where('recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?', object[:site_id], object[:from_date], object[:to_date])
                  .select('nps.*, recordings.session_id, visitors.id visitor_id, visitors.visitor_id visitor_visitor_id')
                  .order(sort_by(sort))
                  .page(page)
                  .per(size)

        {
          items: map_results(results),
          pagination: {
            page_size: size,
            total: results.total_count,
            sort: sort
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
          {
            id: r.id,
            score: r.score,
            contact: r.contact,
            comment: r.comment,
            session_id: r.session_id,
            recording_id: r.recording_id,
            timestamp: r.created_at.utc.iso8601,
            visitor: {
              id: r.visitor_id,
              visitor_id: r.visitor_visitor_id
            }
          }
        end
      end
    end
  end
end
