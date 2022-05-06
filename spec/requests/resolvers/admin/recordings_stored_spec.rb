# frozen_string_literal: true

require 'rails_helper'

recordings_stored_admin_query = <<-GRAPHQL
  query {
    admin {
      recordingsStored {
        count
        date
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::RecordingsStored, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(recordings_stored_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      create(:recording, created_at: Date.new(2022, 5, 1))
      create(:recording, created_at: Date.new(2022, 5, 1))
      create(:recording, created_at: Date.new(2022, 5, 1))
      create(:recording, created_at: Date.new(2022, 5, 3))
      create(:recording, created_at: Date.new(2022, 5, 6))
      create(:recording, created_at: Date.new(2022, 5, 6))
    end

    it 'returns the count' do
      response = graphql_request(recordings_stored_admin_query, {}, user)

      expect(response['data']['admin']['recordingsStored']).to eq([
        {
          'date' => '2022-05-01',
          'count' => 3
        },
        {
          'date' => '2022-05-03',
          'count' => 1
        },
        {
          'date' => '2022-05-06',
          'count' => 2
        }
      ])
    end
  end
end
