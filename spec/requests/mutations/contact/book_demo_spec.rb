# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

book_demo_mutation = <<-GRAPHQL
  mutation($first_name: String!, $last_name: String!, $email: String!, $telephone: String!, $company_name: String!, $traffic: String!, $message: String!) {
    bookDemo(input: { firstName: $first_name, lastName: $last_name, email: $email, telephone: $telephone, companyName: $company_name, traffic: $traffic, message: $message }) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::BookDemo, type: :request do
 subject do
    variables = {
      first_name: 'Bob',
      last_name: 'Dylan',
      email: 'big-bobby@gmail.com',
      telephone: '12312312312',
      company_name: 'Squark',
      traffic: 'Shit loads',
      message: 'Yo'
    }
    graphql_request(book_demo_mutation, variables, nil)
  end

  it 'returns the sent message' do
    response = subject['data']['bookDemo']['message']
    expect(response).to eq 'Sent'
  end

  it 'sends the email' do
    expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
