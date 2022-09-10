# frozen_string_literal: true

module Resolvers
  module Feedback
    class NpsGroups < Resolvers::Base
      type Types::Feedback::NpsGroups, null: false

      def resolve_with_timings # rubocop:disable Metrics/AbcSize
        sql = <<-SQL
          SELECT nps.score
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?
        SQL

        variables = [
          object.site.id,
          object.range.from,
          object.range.to,
        ]

        results = Sql.execute(sql, variables)

        out = {
          promoters: 0,
          passives: 0,
          detractors: 0
        }

        results.each do |r|
          if r['score'] <= 6
            out[:detractors] += 1
          elsif [7, 8].include?(r['score'])
            out[:passives] += 1
          else
            out[:promoters] += 1
          end
        end

        out
      end
    end
  end
end
