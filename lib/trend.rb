# frozen_string_literal: true

class Trend
  def self.offset_period(from_date, to_date)
    # Same day is pointless because you're comparing it against
    # itself, so always do at least one day
    diff = (to_date - from_date).days < 1.day ? 1.day : (to_date - from_date)

    [from_date - diff, to_date - diff]
  end
end
