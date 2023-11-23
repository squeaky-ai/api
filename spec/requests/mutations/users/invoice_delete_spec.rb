# frozen_string_literal: true

require 'rails_helper'

user_invoice_delete_mutation = <<-GRAPHQL
  mutation($input: UsersInvoiceDeleteInput!) {
    userInvoiceDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::InvoiceDelete, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:partner) { create(:partner, user:) }
  let!(:invoice) { create(:partner_invoice, partner:) }

  subject do
    variables = {
      input: {
        id: invoice.id
      }
    }

    graphql_request(user_invoice_delete_mutation, variables, user)
  end

  it 'returns nil' do
    expect(subject['data']['userInvoiceDelete']).to eq(nil)
  end

  it 'deletes the record' do
    subject
    expect { invoice.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
