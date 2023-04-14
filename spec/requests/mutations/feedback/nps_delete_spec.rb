# typed: false
# frozen_string_literal: true

require 'rails_helper'

nps_delete_mutation = <<-GRAPHQL
  mutation($input: NpsDeleteInput!) {
    npsDelete(input: $input) {
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
        input: {
          siteId: site.id,
          npsId: SecureRandom.uuid
        }
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
    let!(:nps) { create(:nps, recording: recording) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          npsId: nps.id
        }
      }
      graphql_request(nps_delete_mutation, variables, user)
    end

    it 'deletes the nps' do
      expect { subject }.to change { site.reload.nps.size }.from(1).to(0)
    end
  end
end
