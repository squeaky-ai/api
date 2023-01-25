# frozen_string_literal: true

class Plans
  def self.find_by_plan_id(plan_id)
    Plans.to_a.find { |plan| plan[:id] == plan_id }
  end

  def self.find_by_pricing_id(pricing_id)
    matching_plan = Plans.to_a.find do |plan|
      (plan[:pricing] || []).find { |price| price[:id] == pricing_id }
    end

    matching_plan&.deep_symbolize_keys
  end

  def self.find_by_provider(provider, plan_id)
    Plans.to_a.find do |plan|
      (plan[:integrations] || {})[provider.to_sym] == plan_id
    end
  end

  def self.next_plan_name(plan_id)
    plans = Plans.to_a
    index = plans.find_index { |plan| plan[:id] == plan_id }

    next_plan = plans[index + 1] if index

    return nil unless next_plan

    next_plan[:name]
  end

  def self.to_a
    Rails.configuration.plans['plans']
  end

  def self.free_plan
    Plans.to_a.find { |plan| plan[:free] }
  end
end
