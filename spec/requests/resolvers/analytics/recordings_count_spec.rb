# frozen_string_literal: true

require 'rails_helper'

analytics_recordings_count_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        recordingsCount {
          total
          new
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::RecordingsCount, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_recordings_count_query, variables, user)
    end

    it 'returns the total number of recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['total']).to eq 0
    end

    it 'returns the number of new recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['new']).to eq 0
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_recordings_count_query, variables, user)
    end

    it 'returns the total number of recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['total']).to eq 2
    end

    it 'returns the number of new recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['new']).to eq 2
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 7, 6).to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_recordings_count_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['total']).to eq 2
    end

    it 'returns the number of new recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['new']).to eq 2
    end
  end

  context 'when some of the recordings have been viewed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 7).to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.new(2021, 8, 6).to_i * 1000,
          viewed: true
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_recordings_count_query, variables, user)
    end

    it 'returns the total number of recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['total']).to eq 2
    end

    it 'returns the number of new recordings' do
      response = subject['data']['site']['analytics']
      expect(response['recordingsCount']['new']).to eq 1
    end
  end
end
