# frozen_string_literal: true

require 'rails_helper'

user_delete_mutation = <<-GRAPHQL
  mutation {
    userDelete(input: {}) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::UserDelete, type: :request do
  let(:user) { create_user }

  before do
    stub = double
    allow(stub).to receive(:deliver_now)
    allow(UserMailer).to receive(:destroyed).and_return(stub)
  end

  subject do
    variables = {}
    graphql_request(user_delete_mutation, variables, user)
  end

  it 'returns nil' do
    expect(subject['data']['userDelete']).to be_nil
  end

  it 'deletes the record' do
    subject
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'sends the email' do
    subject
    expect(UserMailer).to have_received(:destroyed)
  end
end
