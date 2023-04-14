# typed: false
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

RSpec.describe Resolvers::Admin::RecordingsStored, type: :request, truncate_click_house: true do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(recordings_stored_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 1).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 1).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 1).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 3).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          disconnected_at: Time.new(2022, 5, 6).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
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
