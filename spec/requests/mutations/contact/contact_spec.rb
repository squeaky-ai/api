# typed: false
# frozen_string_literal: true

require 'rails_helper'

contact_mutation = <<-GRAPHQL
  mutation($input: ContactInput!) {
    contact(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::Contact, type: :request do
 subject do
    variables = {
      input: {
        firstName: 'Bob',
        lastName: 'Dylan',
        email: 'big-bobby@gmail.com',
        subject: '$$$',
        message: 'Yo'
      }
    }
    graphql_request(contact_mutation, variables, nil)
  end

  it 'returns the sent message' do
    response = subject['data']['contact']['message']
    expect(response).to eq 'Sent'
  end

  it 'sends the email' do
    expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
