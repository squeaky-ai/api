# frozen_string_literal: true

class PlansDecorator
  include ActionView::Helpers::NumberHelper

  def initialize(plans:, site:)
    @site = site
    @plans = plans
  end

  def decrorate
    [
      {
        id: 'free',
        name: 'Free',
        plan: free_plan,
        description: 'Simple analytics for small sites and hobbyists.',
        show: true,
        current: active_plan?(free_plan),
        usage: usage(free_plan),
        includes_capabilities_from: nil,
        capabilities: [
          'Website dashboard',
          'Visitor profiles',
          'Session recording',
          'Site analytics',
          'Heatmaps (Click)'
        ],
        options: []
      },
      {
        id: 'starter',
        name: 'Starter',
        plan: starter_plan,
        description: 'Meaningful analytics for growing businesses.',
        show: true,
        current: active_plan?(starter_plan),
        usage: usage(starter_plan),
        includes_capabilities_from: 'Free',
        capabilities: [
          'Heatmaps (Click and Scroll)',
          'Survey library'
        ],
        options: []
      },
      {
        id: 'light',
        name: 'Light',
        plan: light_plan,
        description: nil,
        show: active_plan?(light_plan),
        current: active_plan?(light_plan),
        usage: [],
        includes_capabilities_from: nil,
        capabilities: [],
        options: []
      },
      {
        id: 'plus',
        name: 'Plus',
        plan: plus_plan,
        description: nil,
        show: active_plan?(plus_plan),
        current: active_plan?(plus_plan),
        usage: [],
        includes_capabilities_from: nil,
        capabilities: [],
        options: []
      },
      {
        id: 'business',
        name: 'Business',
        plan: business_plan,
        description: 'Comprehensive analytics for customer-obsessed teams.',
        show: true,
        current: active_plan?(business_plan),
        usage: usage(business_plan),
        includes_capabilities_from: 'Starter',
        capabilities: [
          'Page analytics',
          'Heatmaps (All)',
          'Event tracking',
          'Error tracking',
          'Segments (up to 25)',
          'Journey mapping'
        ],
        options: []
      },
      {
        id: 'enterprise',
        name: 'Enterprise',
        plan: nil,
        description: 'Tailor made insights for large organisations.',
        show: true,
        current: false,
        usage: usage(
          max_monthly_recordings: nil,
          team_members: nil,
          websites: nil,
          data_storage_months: nil
        ),
        includes_capabilities_from: 'Business',
        capabilities: [
          'Custom surveys (Unlimited)',
          'Segments (Unlimited)'
        ],
        options: [
          'Single Sign-On (SSO)',
          'Audit Trail',
          'Private Instance',
          'Enterprise SLA\'s'
        ]
      }
    ]
  end

  private

  attr_reader :site, :plans

  def free_plan
    @free_plan ||= Plans.find_by_plan_id('05bdce28-3ac8-4c40-bd5a-48c039bd3c7f')
  end

  def light_plan
    @light_plan ||= Plans.find_by_plan_id('094f6148-22d6-4201-9c5e-20bffb68cc48')
  end

  def plus_plan
    @plus_plan ||= Plans.find_by_plan_id('f20c93ec-172f-46c6-914e-6a00dff3ae5f')
  end

  def starter_plan
    @starter_plan ||= Plans.find_by_plan_id('b5be7346-b896-4e4f-9598-e206efca98a6')
  end

  def business_plan
    @business_plan ||= Plans.find_by_plan_id('b2054935-4fdf-45d0-929b-853cfe8d4a1c')
  end

  def active_plan?(plan)
    return false unless site

    site.plan.plan_id == plan[:id]
  end

  def usage(plan)
    [
      formatted_usage(
        'plans.visits_per_month',
        plan[:max_monthly_recordings] || 'Custom'
      ),

      formatted_usage(
        'plans.team_members',
        plan[:team_member_limit] || 'Unlimited'
      ),

      formatted_usage(
        'plans.websites',
        plan[:site_limit] || 'Unlimited'
      ),

      formatted_usage(
        plan[:data_storage_months] ? 'plans.data_retention' : 'plans.data_retention_custom',
        plan[:data_storage_months] || 'Custom'
      )
    ]
  end

  def formatted_usage(key, count)
    "#{number_with_delimiter(count)} #{I18n.t(key, count:)}"
  end
end
