# frozen_string_literal: true

class Nps < ApplicationRecord
  belongs_to :recording

  def self.get_scores_between(site_id, from_date, to_date)
    results = select('nps.created_at, nps.score')
              .joins(:recording)
              .where(
                'recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ?',
                site_id,
                from_date,
                to_date
              )

    results.map do |r|
      {
        score: r.score,
        timestamp: r.created_at.utc
      }
    end
  end

  def self.get_score_between(site_id, from_date, to_date)
    scores = get_scores_between(site_id, from_date, to_date)

    calculate_scores(scores)
  end

  def self.calculate_scores(scores)
    values = scores.pluck(:score)
    total = scores.size

    return 0 if total.zero?

    promoters = values.filter { |v| v >= 9 }.size
    detractors = values.filter { |v| v <= 6 }.size

    (Maths.percentage(promoters.to_f, total) - Maths.percentage(detractors, total)).round(2)
  end
end
