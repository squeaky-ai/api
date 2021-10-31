# frozen_string_literal: true

# Load the plan config
class Plan
  PLANS = YAML.load_file(File.expand_path('../config/plans.yml', __dir__))

  def initialize(plan)
    @config = PLANS["plan_#{plan}"]
  end

  def max_team_members
    @config['max_team_members']
  end

  def max_monthly_recordings
    @config['max_monthly_recordings']
  end

  def monthly_price
    @config['monthly_price']
  end
end
