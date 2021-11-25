# frozen_string_literal: true

module Types
  class NpsStatsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      {
        displays: displays_count(site_id, from_date, to_date),
        ratings: ratings_count(site_id, from_date, to_date)
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
