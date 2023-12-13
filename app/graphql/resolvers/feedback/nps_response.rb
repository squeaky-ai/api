# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsResponse < Resolvers::Base
      type Types::Feedback::NpsResponse, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 10
      argument :sort, Types::Feedback::NpsResponseSort, required: false, default_value: 'timestamp__desc'
      argument :filters, Types::Feedback::NpsResponseFilters, required: false, default_value: nil

      def resolve(page:, size:, sort:, filters:)
        query = Nps.joins(recording: :visitor)
          .where(
            'recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?',
            object.site.id,
            object.range.from,
            object.range.to
          )
          .select('
                     nps.*,
                     recordings.session_id,
                     recordings.viewport_x,
                     recordings.viewport_y,
                     recordings.device_x,
                     recordings.device_y,
                     recordings.useragent,
                     visitors.id visitor_id,
                     visitors.visitor_id visitor_visitor_id
                   ')

        query = filter_by_follow_up(filters, query) if filters
        query = filter_by_outcome_type(filters, query) if filters

        results = query
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

      def filter_by_follow_up(filters, query)
        return query if filters[:follow_up_comment].nil?

        clause = filters[:follow_up_comment] ? 'comment IS NOT NULL' : 'comment IS NULL'

        query.where(clause)
      end

      def filter_by_outcome_type(filters, query)
        return query if filters[:outcome_type].nil?

        clauses = {
          'Detractor' => 'score < 7',
          'Passive' => 'score > 6 AND score < 9',
          'Promoter' => 'score > 8'
        }

        query.where(clauses[filters[:outcome_type]])
      end

      def map_results(results)
        results.map do |r|
          useragent = UserAgent.parse(r.useragent)

          {
            id: r.id,
            score: r.score,
            contact: r.contact,
            comment: r.comment,
            session_id: r.session_id,
            email: r.email,
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
