# frozen_string_literal: true

class Trend
  def self.offset_period(from_date, to_date)
    from = Date.strptime(from_date, '%Y-%m-%d')
    to = Date.strptime(to_date, '%Y-%m-%d')

    # Same day is pointless because you're comparing it against
    # itself, so always do at least one day
    diff = (to - from).days < 1.day ? 1.day : (to - from)

    [from - diff, to - diff]
  end
end
