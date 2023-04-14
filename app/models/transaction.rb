# typed: false
# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :billing

  def plan
    Plans.find_by_pricing_id(pricing_id)
  end

  def period_start_at
    Time.at(period_from).utc
  end

  def period_end_at
    Time.at(period_to).utc
  end
end
