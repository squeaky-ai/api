# frozen_string_literal: true

require 'rails_helper'

site_last_recording_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      daysSinceLastRecording
    }
  }
GRAPHQL

RSpec.describe Resolvers::Recordings::DaysSinceLastRecording, type: :request do
  context 'when there have been no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_last_recording_query, variables, user)
    end

    it 'returns -1' do
      response = subject['data']['site']['daysSinceLastRecording']
      expect(response).to eq(-1)
    end
  end

  context 'when there is a recording' do
    context 'when the recording is from today' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      let(:recording) do
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: Time.current.to_i * 1000
        }
      end

      before do
        ClickHouse::Recording.insert do |buffer|
          buffer << recording
        end
      end

      subject do
        variables = { site_id: site.id }
        graphql_request(site_last_recording_query, variables, user)
      end

      it 'returns the number of days' do
        response = subject['data']['site']['daysSinceLastRecording']
        expect(response).to eq 0
      end
    end

    context 'when the recording is from the past' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      let(:recording) do
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: (Time.current.utc - 5.days).to_i * 1000
        }
      end

      before do
        ClickHouse::Recording.insert do |buffer|
          buffer << recording
        end
      end

      subject do
        variables = { site_id: site.id }
        graphql_request(site_last_recording_query, variables, user)
      end

      it 'returns the number of days' do
        response = subject['data']['site']['daysSinceLastRecording']
        expect(response).to eq 5
      end
    end
  end

  context 'when there are several recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 1.day.ago.to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 2.days.ago.to_i * 1000
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          disconnected_at: 3.days.ago.to_i * 1000
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_last_recording_query, variables, user)
    end

    it 'returns the nearest recordings days' do
      response = subject['data']['site']['daysSinceLastRecording']
      expect(response).to eq 1
    end
  end
end
