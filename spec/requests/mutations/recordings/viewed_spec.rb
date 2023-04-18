# frozen_string_literal: true

require 'rails_helper'

recording_viewed_mutation = <<-GRAPHQL
  mutation($input: RecordingsViewedInput!) {
    recordingViewed(input: $input) {
      id
      viewed
    }
  }
GRAPHQL

RSpec.describe Mutations::Recordings::Viewed, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: 234234 
        }
      }
      graphql_request(recording_viewed_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Recording not found'
    end
  end

  context 'when the recording does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: recording.id 
        }
      }
      graphql_request(recording_viewed_mutation, variables, user)
    end

    it 'marks the site as recorded' do
      response = subject['data']['recordingViewed']
      expect(response['viewed']).to be true
    end

    it 'updates the recording in the database' do
      expect { subject }.to change { Recording.find_by(id: recording.id).viewed }.from(false).to(true)
    end

    it 'marks the visitor as not-new' do
      expect { subject }.to change { recording.visitor.reload.new }.from(true).to(false)
    end
  end

  context 'when a superuser is viewing' do
    let(:user) { create(:user, superuser: true) }
    let(:site) { create(:site_with_team) }
    let(:recording) { create(:recording, site: site) }

    subject do
      variables = {
        input: { 
          siteId: site.id, 
          recordingId: recording.id 
        }
      }
      graphql_request(recording_viewed_mutation, variables, user)
    end

    it 'does not mark the site as recorded' do
      response = subject['data']['recordingViewed']
      expect(response['viewed']).to be false
    end

    it 'does not update the recording in the database' do
      expect { subject }.not_to change { Recording.find_by(id: recording.id).viewed }
    end

    it 'does not mark the visitor as not-new' do
      expect { subject }.not_to change { recording.visitor.reload.new }
    end
  end
end
