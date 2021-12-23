# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

nps_delete_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $nps_id: ID!) {
    npsDelete(input: { siteId: $site_id, npsId: $nps_id }) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::NpsDelete, type: :request do
  context 'when the feedback does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        site_id: site.id,
        nps_id: SecureRandom.uuid
      }
      graphql_request(nps_delete_mutation, variables, user)
    end

    it 'returns an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'NPS response not found'
    end
  end

  context 'when the feedback does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }
    let(:nps) { create(:nps, recording: recording) }

    before { nps }

    subject do
      variables = {
        site_id: site.id,
        nps_id: nps.id
      }
      graphql_request(nps_delete_mutation, variables, user)
    end

    it 'deletes the nps' do
      expect { subject }.to change { site.reload.nps.size }.from(1).to(0)
    end
  end
end
