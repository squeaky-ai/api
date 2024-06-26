# frozen_string_literal: true

require 'rails_helper'

visitor_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        id
        recordingCount {
          total
          new
        }
        pageViewsCount {
          total
          unique
        }
        firstViewedAt {
          iso8601
        }
        lastActivityAt {
          iso8601
        }
        language
        devices {
          viewportX
          viewportY
          deviceX
          deviceY
          deviceType
          browserName
          browserDetails
        }
        countries {
          code
          name
        }
        linkedData
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::GetOne, type: :request do
  context 'when the visitor does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, visitor_id: 2390423423 }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['visitor']
      expect(response).to be nil
    end
  end

  context 'when there is a visitor with a recording' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    before do
      create(:recording, site:, visitor:)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns the visitor' do
      response = subject['data']['site']['visitor']
      expect(response).not_to be nil
    end

    it 'returns the recording count' do
      response = subject['data']['site']['visitor']
      expect(response['recordingCount']['total']).to eq 1
      expect(response['recordingCount']['new']).to eq 1
    end

    it 'returns the page views count' do
      response = subject['data']['site']['visitor']
      expect(response['pageViewsCount']['total']).to eq 1
      expect(response['pageViewsCount']['unique']).to eq 1
    end
  end

  context 'when there are no external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:visitor) { create(:visitor, site_id: site.id) }

    before do
      create(:recording, site:, visitor:)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['visitor']
      expect(response['linkedData']).to be nil
    end
  end

  context 'when there are some external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:external_attributes) { { name: 'Bob Dylan', email: 'bobby_d@gmail.com' } }
    let(:visitor) { create(:visitor, site_id: site.id, external_attributes:) }

    before do
      create(:recording, site:, visitor:)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns the attributes' do
      response = subject['data']['site']['visitor']
      expect(response['linkedData']).to eq external_attributes.to_json
    end
  end
end
