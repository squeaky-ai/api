# frozen_string_literal: true

require 'rails_helper'

user_update_mutation = <<-GRAPHQL
  mutation($first_name: String, $last_name: String, $email: String) {
    userUpdate(input: { firstName: $first_name, lastName: $last_name, email: $email }) {
      id
      firstName
      lastName
      email
    }
  }
GRAPHQL

RSpec.describe Mutations::UserUpdate, type: :request do
  let(:user) { create_user }
  let(:first_name) { Faker::Name.first_name }
  let(:last_name) { Faker::Name.last_name }
  let(:email) { Faker::Internet.email }

  subject do
    update = { first_name: first_name, last_name: last_name, email: email }
    graphql_request(user_update_mutation, update, user)
  end

  it 'returns the updated user' do
    expect(subject['data']['userUpdate']).to eq(
      'id' => user.id.to_s,
      'firstName' => first_name,
      'lastName' => last_name,
      'email' => email
    )
  end

  it 'updates the record' do
    subject
    user.reload
    expect(user.first_name).to eq first_name
    expect(user.last_name).to eq last_name
    expect(user.email).to eq email
  end
end
