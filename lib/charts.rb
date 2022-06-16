# frozen_string_literal: true

class Charts
  POSTGRES_FORMATS = {
    hour: 'HH24',
    day: 'DDD',
    week: 'WW',
    year: 'YYYY/MM'
  }.freeze

  CLICKHOUSE_FORMATS = {
    hour: '%H',
    day: '%j',
    week: '%V',
    year: '%Y/%m'
  }.freeze

  def self.date_groups(from_date, to_date, clickhouse: false)
    diff_in_days = (to_date - from_date).to_i

    formats = clickhouse ? CLICKHOUSE_FORMATS : POSTGRES_FORMATS

    # Group all visitors by hours
    return [formats[:hour], 'hourly', 24] if diff_in_days.zero?

    # Group the visitors by the day of the year
    return [formats[:day], 'daily', diff_in_days] if diff_in_days <= 21

    # Group the visitors by the week of the year
    return [formats[:week], 'weekly', diff_in_days / 7] if diff_in_days > 21 && diff_in_days < 90

    # Group the visitors by the year/month
    [formats[:year], 'monthly', diff_in_days / 30]
  end
end
