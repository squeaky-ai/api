# frozen_string_literal: true

module Types
  # The counts grouped
  class NpsGroupsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      sql = <<-SQL
        SELECT nps.score
        FROM nps
        INNER JOIN recordings ON recordings.id = nps.recording_id
        WHERE recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?
      SQL

      results = Sql.execute(sql, [site_id, from_date, to_date])

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
