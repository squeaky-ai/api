# frozen_string_literal: true

require 'rails_helper'

site_last_recording_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(id: $site_id) {
      daysSinceLastRecording
    }
  }
GRAPHQL

RSpec.describe Types::RecordingExtension, type: :request do
  context 'when there have been no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

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
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id }
        graphql_request(site_last_recording_query, variables, user)
      end

      before { create_recording({ disconnected_at: DateTime.now }, site: site) }

      it 'returns the number of days' do
        response = subject['data']['site']['daysSinceLastRecording']
        expect(response).to eq 0
      end
    end

    context 'when the recording is from the past' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id }
        graphql_request(site_last_recording_query, variables, user)
      end

      before { create_recording({ disconnected_at: DateTime.now - 5.days }, site: site) }

      it 'returns the number of days' do
        response = subject['data']['site']['daysSinceLastRecording']
        expect(response).to eq 5
      end
    end
  end

  context 'when there are several recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_last_recording_query, variables, user)
    end

    before do
      create_recording({ disconnected_at: DateTime.now - 1.days }, site: site)
      create_recording({ disconnected_at: DateTime.now - 3.days }, site: site)
      create_recording({ disconnected_at: DateTime.now - 5.days }, site: site)
    end

    it 'returns the nearest recordings days' do
      response = subject['data']['site']['daysSinceLastRecording']
      expect(response).to eq 1
    end
  end
end
