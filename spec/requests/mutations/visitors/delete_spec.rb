# frozen_string_literal: true

require 'rails_helper'

visitor_delete_mutation = <<-GRAPHQL
  mutation($input: VisitorsDeleteInput!) {
    visitorDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Visitors::Delete, type: :request do
  context 'when the visitor does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          visitorId: SecureRandom.base36
        }
      }
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
    let!(:recording) { create(:recording, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          visitorId: recording.visitor.id
        }
      }
      graphql_request(visitor_delete_mutation, variables, user)
    end

    it 'returns without the visitor' do
      response = subject['data']['visitorDelete']
      expect(response).to eq nil
    end

    it 'deletes the visitor' do
      expect { subject }.to change { site.visitors.size }.from(1).to(0)
    end

    it 'deletes the recordings' do
      subject
      expect(RecordingDeleteJob).to have_been_enqueued.once.with(match_array([recording.id]))
    end
  end
end
