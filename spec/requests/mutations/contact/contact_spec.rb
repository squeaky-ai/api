# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

contact_mutation = <<-GRAPHQL
  mutation($first_name: String!, $last_name: String!, $email: String!, $subject: String!, $message: String!) {
    contact(input: { firstName: $first_name, lastName: $last_name, email: $email, subject: $subject, message: $message }) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::Contact, type: :request do
 subject do
    variables = {
      first_name: 'Bob',
      last_name: 'Dylan',
      email: 'big-bobby@gmail.com',
      subject: '$$$',
      message: 'Yo'
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
