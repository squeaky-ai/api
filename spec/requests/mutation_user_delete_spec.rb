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
    puts '@@@@', subject['errors']
    expect(subject['data']['userDelete']).to be_nil
  end

  it 'deletes the record' do
    user.reload
    expect(user).to be_nil
  end
end
