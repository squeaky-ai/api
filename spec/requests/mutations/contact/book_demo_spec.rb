# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

book_demo_mutation = <<-GRAPHQL
  mutation($input: ContactDemoInput!) {
    bookDemo(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Contact::BookDemo, type: :request do
 subject do
    variables = {
      input: {
        firstName: 'Bob',
        lastName: 'Dylan',
        email: 'big-bobby@gmail.com',
        telephone: '12312312312',
        companyName: 'Squark',
        traffic: 'Shit loads',
        message: 'Yo'
      }
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
