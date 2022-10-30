# frozen_string_literal: true

require 'rails_helper'

contact_partners_mutation = <<-GRAPHQL
  mutation($input: ContactPartnersInput!) {
    contactPartners(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::Partners, type: :request do
 subject do
    variables = {
      input: {
        firstName: 'Bob',
        lastName: 'Dylan',
        email: 'big-bobby@gmail.com',
        name: 'Squeaky',
        description: 'Hello',
        clientCount: 'Loads'
      }
    }
    graphql_request(contact_partners_mutation, variables, nil)
  end

  it 'returns the sent message' do
    response = subject['data']['contactPartners']['message']
    expect(response).to eq 'Sent'
  end

  it 'sends the email' do
    expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
