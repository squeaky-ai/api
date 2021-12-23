# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

visitor_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $visitor_id: ID!) {
    visitorDelete(input: { siteId: $site_id, visitorId: $visitor_id }) {
      id
      visitors {
        items {
          id
        }
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Visitors::Delete, type: :request do
  context 'when the visitor does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, visitor_id: SecureRandom.base36 }
      graphql_request(visitor_delete_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Visitor not found'
    end
  end

  context 'when the visitor exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create_recording(site: site, visitor: create_visitor) }

    before { recording }

    subject do
      variables = { site_id: site.id, visitor_id: recording.visitor.id }
      graphql_request(visitor_delete_mutation, variables, user)
    end

    it 'returns without the visitor' do
      response = subject['data']['visitorDelete']['visitors']
      expect(response['items']).to eq([])
    end

    it 'deletes the visitor' do
      expect { subject }.to change { site.visitors.size }.from(1).to(0)
    end

    it 'deletes the recordings' do
      expect { subject }.to change { site.recordings.size }.from(1).to(0)
    end
  end
end
