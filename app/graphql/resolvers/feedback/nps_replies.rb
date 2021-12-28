# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsReplies < Resolvers::Base
      type Types::Feedback::NpsReplies, null: false

      def resolve
        responses = get_replies(object[:site_id], object[:from_date], object[:to_date])

        {
          trend: get_trend(object[:site_id], object[:from_date], object[:to_date], responses),
          responses: responses
        }
      end

      private

      def get_replies(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT nps.score, nps.created_at
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ? AND recordings.status IN (?)
        SQL

        variables = [
          site_id,
          from_date,
          to_date,
          [Recording::ACTIVE, Recording::DELETED]
        ]

        results = Sql.execute(sql, variables)

        results.map do |r|
          {
            score: r['score'],
            timestamp: r['created_at'].utc.iso8601
          }
        end
      end

      def get_trend(site_id, from_date, to_date, current_responses)
        offset_dates = offset_dates_by_period(from_date, to_date)
        last_responses = get_replies(site_id, *offset_dates)

        current_responses.size - last_responses.size
      end

      def parse_date(date)
        Date.strptime(date, '%Y-%m-%d')
      end

      def offset_dates_by_period(from_date, to_date)
        from = parse_date(from_date)
        to = parse_date(to_date)

        # Same day is pointless because you're comparing it against
        # itself, so always do at least one day
        diff = (to - from).days < 1.day ? 1.day : (to - from)

        [from - diff, to - diff]
      end
    end
  end
end
