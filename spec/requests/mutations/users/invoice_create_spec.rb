# frozen_string_literal: true

require 'rails_helper'

user_invoice_create_mutation = <<-GRAPHQL
  mutation($input: UsersInvoiceCreateInput!) {
    userInvoiceCreate(input: $input) {
      filename
      amount
      currency
      status
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::InvoiceCreate, type: :request do
  context 'when the user is not a partner' do
    let(:user) { create(:user) }

    subject do
      variables = { 
        input: {
          currency: 'GBP',
          amount: 100,
          filename: 'file.pdf'
        }
      }
      graphql_request(user_invoice_create_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['userInvoiceCreate']).to eq(nil)
    end
  end

  context 'when the user is a partner' do
    let(:user) { create(:user) }
    let!(:partner) { create(:partner, user:) }

    subject do
      variables = { 
        input: {
          currency: 'GBP',
          amount: 100,
          filename: 'file.pdf'
        }
      }
      graphql_request(user_invoice_create_mutation, variables, user)
    end

    it 'creates the invoice' do
      expect(subject['data']['userInvoiceCreate']).to eq(
       'currency' => 'GBP',
        'amount' => 100,
        'filename' => 'file.pdf',
        'status' => 0
      )
    end
  end
end
