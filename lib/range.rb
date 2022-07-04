# frozen_string_literal: true

class Range
  def initialize(from_date, to_date)
    @from_date = from_date
    @to_date = to_date
  end

  def from
    @from_date
  end

  def to
    @to_date # TODO: Return this, or the locked_at when this exists
  end

  def trend_from
    from - offset
  end

  def trend_to
    to - offset
  end

  private

  def offset
    # Same day is pointless because you're comparing it against
    # itself, so always do at least one day
    @offset ||= (to_date - from_date).days < 1.day ? 1.day : (to_date - from_date)
  end
end
