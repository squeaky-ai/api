# frozen_string_literal: true

module Types
  class SentimentRatingsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      current_results = get_results(site_id, from_date, to_date)
      trend_date_range = offset_dates_by_period(from_date, to_date)
      previous_results = get_results(site_id, *trend_date_range)

      {
        score: avg_score(current_results),
        trend: avg_score(current_results) - avg_score(previous_results),
        responses: map_results(current_results)
      }
    end

    private

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

    def get_results(site_id, from_date, to_date)
      Sentiment
        .joins(:recording)
        .where('recordings.site_id = ? AND sentiments.created_at::date >= ? AND sentiments.created_at::date <= ?', site_id, from_date, to_date)
        .select('sentiments.score, sentiments.created_at')
    end

    def avg_score(results)
      return 0 if results.empty?

      values = results.map(&:score)

      values.sum.fdiv(values.size)
    end

    def map_results(results)
      results.map do |r|
        {
          score: r.score,
          timestamp: r.created_at.utc.iso8601
        }
      end
    end
  end
end
