# frozen_string_literal: true

require 'rails_helper'

admin_site_plan_update_mutation = <<-GRAPHQL
  mutation($input: AdminSitePlanUpdateInput!) {
    adminSitePlanUpdate(input: $input) {
      id
      plan {
        tier
        name
        exceeded
        invalid
        support
        maxMonthlyRecordings
        recordingsLockedCount
        visitorsLockedCount
        ssoEnabled
        auditTrailEnabled
        privateInstanceEnabled
        responseTimeHours
        dataStorageMonths
        notes
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SitePlanUpdate, type: :request do
  context 'when the user does not own any sites' do
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
          notes: 'Hello there'
        }
      }
  
      graphql_request(admin_site_plan_update_mutation, variables, user)
    end

    it 'returns the updated plan data' do
      expect(subject['data']['adminSitePlanUpdate']).to eq(
        'id' => site.id.to_s,
        'plan' => {
          "auditTrailEnabled" => true,
          "dataStorageMonths" => 24,
          "exceeded" => false,
          "invalid" => false,
          "maxMonthlyRecordings" => 1000,
          "name" => "Free",
          "notes" => "Hello there",
          "privateInstanceEnabled" => true,
          "recordingsLockedCount" => 0,
          "responseTimeHours" => 12,
          "ssoEnabled" => true,
          "support" => ["Phone", "Chat"],
          "tier" => 0,
          "visitorsLockedCount" => 0,
        }
      )
    end
  end
end