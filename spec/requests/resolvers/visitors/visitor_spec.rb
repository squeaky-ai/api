# frozen_string_literal: true

require 'rails_helper'

visitor_query = <<-GRAPHQL
  query($site_id: ID!, $visitor_id: ID!) {
    site(siteId: $site_id) {
      visitor(visitorId: $visitor_id) {
        id
        recordingsCount {
          total
          new
        }
        pageViewsCount {
          total
          unique
        }
        firstViewedAt
        lastActivityAt
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
        attributes
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::Visitor, type: :request do
  context 'when the visitor does not exist' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

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
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do  
      create_recording({ pages: [create_page(url: '/')] }, site: site, visitor: visitor)
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
      expect(response['recordingsCount']['total']).to eq 1
      expect(response['recordingsCount']['new']).to eq 1
    end

    it 'returns the page views count' do
      response = subject['data']['site']['visitor']
      expect(response['pageViewsCount']['total']).to eq 1
      expect(response['pageViewsCount']['unique']).to eq 1
    end
  end

  context 'when the visitior has recordings but they were soft deleted' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do  
      create_recording({ pages: [create_page(url: '/')], deleted: true }, site: site, visitor: visitor)
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
      expect(response['recordingsCount']['total']).to eq 0
      expect(response['recordingsCount']['new']).to eq 0
    end

    it 'returns the page views count' do
      response = subject['data']['site']['visitor']
      expect(response['pageViewsCount']['total']).to eq 1
      expect(response['pageViewsCount']['unique']).to eq 1
    end
  end

  context 'when there are no external attributes' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:visitor) { create_visitor }

    before do
      create_recording(site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['visitor']
      expect(response['attributes']).to be nil
    end
  end

  context 'when there are some external attributes' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:external_attributes) { { name: 'Bob Dylan', email: 'bobby_d@gmail.com' } }
    let(:visitor) { create_visitor(external_attributes: external_attributes) }

    before do
      create_recording(site: site, visitor: visitor)
    end

    subject do
      variables = { site_id: site.id, visitor_id: visitor.id }
      graphql_request(visitor_query, variables, user)
    end

    it 'returns the attributes' do
      response = subject['data']['site']['visitor']
      expect(response['attributes']).to eq external_attributes.to_json
    end
  end
end
