# frozen_string_literal: true

module WeeklyReviewService
  class FeedbackNps < Base
    def self.fetch(site, from_date, to_date)
      {
        enabled: site.nps_enabled?,
        score: Nps.get_score_between(site.id, from_date, to_date)
      }
    end
  end
end
