# frozen_string_literal: true

class Plans
  def self.find_by_pricing_id(pricing_id)
    matching_plan = to_a.find do |plan|
      (plan[:pricing] || []).find { |price| price[:id] == pricing_id }
    end

    matching_plan&.deep_symbolize_keys
  end

  def self.next_tier_name(plan_id)
    plans = Plans.to_a
    index = plans.find_index { |plan| plan[:id] == plan_id }

    next_plan = plans[index + 1] if index

    return nil unless next_plan

    next_plan[:name]
  end

  def self.to_a
    Rails.configuration.plans.values
  end
end
