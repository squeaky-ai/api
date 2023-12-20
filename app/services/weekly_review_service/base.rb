# frozen_string_literal: true

module WeeklyReviewService
  class Base
    def self.milliseconds_to_mmss(milliseconds = 0)
      Time.at(milliseconds.abs / 1000).utc.strftime('%-Mm %-Ss')
    end
  end
end
