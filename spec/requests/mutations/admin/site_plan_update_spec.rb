# frozen_string_literal: true

require 'rails_helper'

admin_site_plan_update_mutation = <<-GRAPHQL
  mutation($input: AdminSitePlanUpdateInput!) {
    adminSitePlanUpdate(input: $input) {
      id
      plan {
        name
        planId
        free
        enterprise
        deprecated
        exceeded
        invalid
        support
        maxMonthlyRecordings
        ssoEnabled
        auditTrailEnabled
        privateInstanceEnabled
        responseTimeHours
        dataStorageMonths
        notes
        teamMemberLimit
        featuresEnabled
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SitePlanUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:site) { create(:site) }

  subject do
    variables = {
      input: {
        siteId: site.id,
        maxMonthlyRecordings: 1000,
        support: ['Phone', 'Chat'],
        responseTimeHours: 12,
        dataStorageMonths: 24,
        ssoEnabled: true,
        auditTrailEnabled: true,
        privateInstanceEnabled: true,
        notes: 'Hello there',
        teamMemberLimit: 1,
        featuresEnabled: ['dashboard'],
      }
    }

    graphql_request(admin_site_plan_update_mutation, variables, user)
  end

  it 'returns the updated plan data' do
    expect(subject['data']['adminSitePlanUpdate']).to eq(
      'id' => site.id.to_s,
      'plan' => {
        'auditTrailEnabled' => true,
        'dataStorageMonths' => 24,
        'exceeded' => false,
        'invalid' => false,
        'maxMonthlyRecordings' => 1000,
        'name' => 'Free',
        'notes' => 'Hello there',
        'privateInstanceEnabled' => true,
        'responseTimeHours' => 12,
        'ssoEnabled' => true,
        'support' => ['Phone', 'Chat'],
        'planId' => '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f',
        'free' => true,
        'enterprise' => false,
        'deprecated' => false,
        'teamMemberLimit' => 1,
        'featuresEnabled' => ['dashboard'],
      }
    )
  end
end
