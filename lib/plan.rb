# frozen_string_literal: true

# Load the plan config
class Plan
  def initialize(plan)
    @config = Rails.configuration.plans["plan_#{plan}".to_sym]
    raise StandardError, 'Plan number is invalid' unless @config
  end

  def name
    @config[:name]
  end

  def max_monthly_recordings
    @config[:max_monthly_recordings]
  end

  def self.find_by_pricing_id(pricing_id)
    matching_plan = to_a.find do |plan|
      (plan[:pricing] || []).find { |price| price[:id] == pricing_id }
    end

    matching_plan&.deep_symbolize_keys
  end

  def self.to_a
    Rails.configuration.plans.values
  end
end
