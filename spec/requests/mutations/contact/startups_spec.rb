# frozen_string_literal: true

require 'rails_helper'

contact_startups_mutation = <<-GRAPHQL
  mutation($input: ContactStartupsInput!) {
    contactStartups(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::Startups, type: :request do
 subject do
    variables = {
      input: {
        firstName: 'Bob',
        lastName: 'Dylan',
        email: 'big-bobby@gmail.com',
        name: 'Squeaky',
        yearsActive: '5',
        trafficCount: 'Loads'
      }
    }
    graphql_request(contact_startups_mutation, variables, nil)
  end

  it 'returns the sent message' do
    response = subject['data']['contactStartups']['message']
    expect(response).to eq 'Sent'
  end

  it 'sends the email' do
    expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
