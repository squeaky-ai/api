# frozen_string_literal: true

require 'rails_helper'

user_password_mutation = <<-GRAPHQL
  mutation($input: UsersPasswordInput!) {
    userPassword(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::Update, type: :request do
  context 'when the current password is incorrect' do
    let(:old_password) { 'oldpassword' }
    let(:new_password) { 'newpassword' }
    let(:user) { create(:user) }

    before { user }

    subject do
      update = { 
        input: {
          password: new_password,
          passwordConfirmation: new_password, 
          currentPassword: old_password 
        }
      }
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
    let(:old_password) { 'oldpassword' }
    let(:new_password) { 'newpassword' }
    let(:user) { create(:user, password: old_password) }

    before { user }

    subject do
      update = { 
        input: {
          password: new_password, 
          passwordConfirmation: new_password, 
          currentPassword: old_password 
        }
      }
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
