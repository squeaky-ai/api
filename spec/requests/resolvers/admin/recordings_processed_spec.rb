# frozen_string_literal: true

require 'rails_helper'

recordings_processed_admin_query = <<-GRAPHQL
  query {
    admin {
      recordingsProcessed
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::RecordingsProcessed, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(recordings_processed_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    it 'returns the count' do
      response = graphql_request(recordings_processed_admin_query, {}, user)

      expect(response['data']['admin']['recordingsProcessed']).to eq 0
    end
  end
end
