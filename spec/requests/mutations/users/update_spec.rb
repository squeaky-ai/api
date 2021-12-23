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

RSpec.describe Mutations::Users::Update, type: :request do
  let(:user) { create(:user) }
  let(:first_name) { 'Jim' }
  let(:last_name) { 'Morrison' }
  let(:email) { 'thelizardking@gmail.com' }

  before do
    stub = double
    allow(stub).to receive(:deliver_now)
    allow(UserMailer).to receive(:updated).and_return(stub)
  end

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

  it 'sends an email' do
    subject
    expect(UserMailer).to have_received(:updated)
  end

  describe 'when the user is updating their details for the first time' do
    # A new user won't have a first or last name
    let(:user) { create(:user, first_name: nil, last_name: nil) }
    let(:first_name) { 'Bob' }
    let(:last_name) { 'Dylan' }

    before do
      stub = double
      allow(stub).to receive(:deliver_now)
      allow(UserMailer).to receive(:updated).and_return(stub)
    end

    subject do
      update = { first_name: first_name, last_name: last_name }
      graphql_request(user_update_mutation, update, user)
    end

    it 'does not send an email' do
      subject
      expect(UserMailer).not_to have_received(:updated)
    end
  end
end
