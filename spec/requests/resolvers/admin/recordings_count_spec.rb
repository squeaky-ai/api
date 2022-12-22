# frozen_string_literal: true

require 'rails_helper'

recordings_count_admin_query = <<-GRAPHQL
  query {
    admin {
      recordingsCount
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::RecordingsCount, type: :request, truncate_click_house: true do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(recordings_count_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
        },
        {
          uuid: SecureRandom.uuid,
        },
        {
          uuid: SecureRandom.uuid,
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    it 'returns the count' do
      response = graphql_request(recordings_count_admin_query, {}, user)

      expect(response['data']['admin']['recordingsCount']).to eq 3
    end
  end
end
