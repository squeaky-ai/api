# frozen_string_literal: true

require 'rails_helper'

nps_groups_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: String!, $to_date: String!) {
    site(siteId: $site_id) {
      nps(fromDate: $from_date, toDate: $to_date) {
        groups {
          promoters
          passives
          detractors
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::NpsGroups, type: :request do
  context 'when there is no data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_groups_query, variables, user)
    end

    it 'returns an empty values' do
      response = subject['data']['site']['nps']
      expect(response['groups']).to eq(
        'promoters' => 0,
        'passives' => 0,
        'detractors' => 0
      )
    end
  end

  context 'when there is some data' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_nps({ score: 9, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_nps({ score: 3, created_at: Time.new(2021, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
      create_nps({ score: 3, created_at: Time.new(2020, 8, 3) }, recording: create_recording(site: site, visitor: visitor))
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(nps_groups_query, variables, user)
    end

    it 'returns the data' do
      response = subject['data']['site']['nps']
      expect(response['groups']).to eq(
        'promoters' => 1,
        'passives' => 0,
        'detractors' => 1
      )
    end
  end
end
