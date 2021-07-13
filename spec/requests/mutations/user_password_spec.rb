# frozen_string_literal: true

require 'rails_helper'

user_password_mutation = <<-GRAPHQL
  mutation($password: String!, $password_confirmation: String!, $current_password: String!) {
    userPassword(input: { password: $password, passwordConfirmation: $password_confirmation, currentPassword: $current_password }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::UserUpdate, type: :request do
  context 'when the current password is incorrect' do
    let(:old_password) { Faker::Lorem.sentence }
    let(:new_password) { Faker::Lorem.sentence }
    let(:user) { create_user }

    before { user }

    subject do
      update = { password: new_password, password_confirmation: new_password, current_password: old_password }
      graphql_request(user_password_mutation, update, user)
    end

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Current password is invalid'
    end

    it 'does not update the record' do
      expect { subject }.not_to change { User.find(user.id).encrypted_password }
    end

    it 'does not send the email' do
      expect { subject }.not_to change { ActionMailer::Base.deliveries.size }
    end
  end

  context 'when the current password is correct' do
    let(:old_password) { Faker::Lorem.sentence }
    let(:new_password) { Faker::Lorem.sentence }
    let(:user) { create_user(password: old_password) }

    before { user }

    subject do
      update = { password: new_password, password_confirmation: new_password, current_password: old_password }
      graphql_request(user_password_mutation, update, user)
    end

    it 'returns the user' do
      expect(subject['data']['userPassword']).to eq('id' => user.id.to_s)
    end

    it 'updates the record' do
      expect { subject }.to change { User.find(user.id).encrypted_password }
    end

    it 'sends the email' do
      expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
    end
  end
end
