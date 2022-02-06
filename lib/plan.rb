# frozen_string_literal: true

# Load the plan config
class Plan
  PLANS = YAML.load_file(File.expand_path('../config/plans.yml', __dir__))

  def initialize(plan)
    @config = PLANS["plan_#{plan}"]
    raise StandardError, 'Plan number is invalid' unless @config
  end

  def name
    @config['name']
  end

  def max_monthly_recordings
    @config['max_monthly_recordings']
  end

  def self.find_by_pricing_id(pricing_id)
    matching_plan = to_a.find do |plan|
      (plan['pricing'] || []).find { |price| price['id'] == pricing_id }
    end

    matching_plan&.deep_symbolize_keys
  end

  def self.to_a
    PLANS.values
  end
end
