# frozen_string_literal: true

class Nps < ApplicationRecord
  belongs_to :recording

  def self.get_scores_between(site_id, from_date, to_date, statuses = [Recording::ACTIVE, Recording::DELETED])
    results = select('nps.created_at, nps.score')
              .joins(:recording)
              .where(
                'recordings.site_id = ? AND nps.created_at::date >= ? AND nps.created_at::date <= ? AND recordings.status IN (?)',
                site_id,
                from_date,
                to_date,
                statuses
              )

    results.map do |r|
      {
        score: r.score,
        timestamp: r.created_at.utc
      }
    end
  end

  def self.get_score_between(site_id, from_date, to_date, statuses = [Recording::ACTIVE, Recording::DELETED])
    scores = get_scores_between(site_id, from_date, to_date, statuses)

    calculate_scores(scores)
  end

  def self.calculate_scores(scores)
    values = scores.map { |s| s[:score] }
    total = scores.size

    return 0 if total.zero?

    promoters = values.filter { |v| v >= 9 }.size
    detractors = values.filter { |v| v <= 6 }.size

    (((promoters.to_f / total) * 100) - ((detractors.to_f / total) * 100)).round(2)
  end
end
