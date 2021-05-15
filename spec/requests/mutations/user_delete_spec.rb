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

  let(:subject) do
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
end
