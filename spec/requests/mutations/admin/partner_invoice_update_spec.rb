# typed: false
# frozen_string_literal: true

require 'rails_helper'

admin_partner_invoice_update_mutation = <<-GRAPHQL
  mutation($input: AdminPartnerInvoiceUpdateInput!) {
    adminPartnerInvoiceUpdate(input: $input) {
      status
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::PartnerInvoiceUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:partner) { create(:partner, user: create(:user)) }
  let!(:invoice) { create(:partner_invoice, partner:) }

  subject do      
    variables = {
      input: {
        id: invoice.id,
        status: 1
      }
    }

    graphql_request(admin_partner_invoice_update_mutation, variables, user)
  end

  it 'returns the updated invoice' do
    expect(subject['data']['adminPartnerInvoiceUpdate']).to eq(
      'status' => 1
    )
  end

  it 'updates the record' do
    expect { subject }.to change { invoice.reload.status }.from(0).to(1)
  end
end
