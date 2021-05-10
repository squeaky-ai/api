# frozen_string_literal: true

require 'rails_helper'

user_delete_mutation = <<-GRAPHQL
  mutation {
    userDelete(input: {}) {
      id
    }
  }
GRAPHQL

RSpec.describe 'Mutation user delete', type: :request do
  let(:user) { create_user }
  let(:subject) { graphql_request(user_delete_mutation, {}, user) }

  it 'returns nil' do
    expect(subject['data']['userDelete']).to be_nil
  end

  it 'deletes the record' do
    subject
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end
