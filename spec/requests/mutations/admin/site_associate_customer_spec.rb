# frozen_string_literal: true

require 'rails_helper'

admin_site_associate_customer_mutation = <<-GRAPHQL
  mutation($input: AdminSiteAssociateCustomerInput!) {
    adminSiteAssociateCustomer(input: $input) {
      id
      billing {
        customerId
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteAssociateCustomer, type: :request do
  context 'when no billing exists' do
    let(:user) { create(:user, superuser: true) }
    let(:site) { create(:site_with_team) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          customerId: 'cus_12342342342'
        }
      }
  
      graphql_request(admin_site_associate_customer_mutation, variables, user)
    end

    it 'returns the updated plan data' do
      expect(subject['data']['adminSiteAssociateCustomer']['billing']).to eq(
        'customerId' => 'cus_12342342342'
      )
    end
  end

  context 'when the billing already exists' do
    let(:user) { create(:user, superuser: true) }
    let(:site) { create(:site_with_team) }

    subject do
      create(:billing, site: site, customer_id: 'cus_12342342342')

      variables = {
        input: {
          siteId: site.id,
          customerId: 'cus_123465756756'
        }
      }
  
      graphql_request(admin_site_associate_customer_mutation, variables, user)
    end

    it 'returns the unmodified site' do
      expect(subject['data']['adminSiteAssociateCustomer']['billing']).to eq(
        'customerId' => 'cus_12342342342'
      )
    end
  end
end
