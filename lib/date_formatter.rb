# frozen_string_literal: true

class DateFormatter
  def self.format(date:, timezone: 'UTC')
    return new(date, timezone).to_date_object if date.is_a?(Date)
    return new(date.to_datetime, timezone).to_date_object if date.is_a?(Time)
    return new(Time.at(date / 1000), timezone).to_date_object if date.is_a?(Integer)

    nil
  end

  def initialize(date, timezone)
    @date = date.in_time_zone(timezone)
  end

  def to_date_object
    {
      iso8601: date.iso8601,
      nice_date: date.strftime('%a, %-d %b %Y %H:%M')
    }
  end

  private

  attr_reader :date, :timezone
end
