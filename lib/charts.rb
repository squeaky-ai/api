# frozen_string_literal: true

class Charts
  def self.date_groups(from_date, to_date)
    diff_in_days = (to_date - from_date).to_i

    # Group all visitors by hours
    return ['HH24', 'hourly', 24] if diff_in_days.zero?

    # Group the visitors by the day of the year
    return ['DDD', 'daily', diff_in_days] if diff_in_days <= 21

    # Group the visitors by the week of the year
    return ['WW', 'weekly', diff_in_days / 7] if diff_in_days > 21 && diff_in_days < 90

    # Group the visitors by the year/month
    ['YYYY/MM', 'monthly', diff_in_days / 30]
  end
end
