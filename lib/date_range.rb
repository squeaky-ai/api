# typed: false
# frozen_string_literal: true

class DateRange
  def initialize(from_date:, to_date:, timezone: 'UTC')
    @from_date = from_date
    @to_date = to_date
    @timezone = timezone
  end

  attr_reader :timezone

  def from
    @from_date
  end

  def to
    @to_date
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
    @offset ||= (to - from).days < 1.day ? 1.day : (to - from)
  end
end
