# frozen_string_literal: true

module Resolvers
  module Nps
    class Stats < Resolvers::Base
      type Types::Nps::Stats, null: false

      def resolve
        {
          displays: displays_count(object[:site_id], object[:from_date], object[:to_date]),
          ratings: ratings_count(object[:site_id], object[:from_date], object[:to_date])
        }
      end

      private

      def displays_count(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT COUNT(id)
          FROM recordings
          WHERE site_id = ? AND created_at::date >= ? AND created_at::date <= ?
        SQL

        results = Sql.execute(sql, [site_id, from_date, to_date])
        results.first['count']
      end

      def ratings_count(site_id, from_date, to_date)
        sql = <<-SQL
          SELECT COUNT(nps.id)
          FROM nps
          INNER JOIN recordings ON recordings.id = nps.recording_id
          WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?
        SQL

        results = Sql.execute(sql, [site_id, from_date, to_date])
        results.first['count']
      end
    end
  end
end
