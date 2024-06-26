# frozen_string_literal: true

class Maths
  def self.percentage(count, total, round: 2)
    return 0 if count.zero? || total.zero?

    ((count.to_f / total) * 100).round(round)
  end

  def self.average(values, round: 2)
    return 0 if values.empty?

    values.sum.fdiv(values.size).round(round)
  end

  def self.to_two_decimal_places(num)
    format('%.2f', num.to_f)
  end
end
