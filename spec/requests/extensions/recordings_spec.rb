# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($id: ID!, $size: Int, $page: Int) {
    site(id: $id) {
      recordings(size: $size, page: $page) {
        items {
          id
          siteId
          viewerId
          active
          language
          duration
          pageCount
          startPage
          exitPage
          deviceType
          browser
          useragent
          viewportX
          viewportY
        }
        pagination {
          pageSize
          pageCount
        }
      }
    }
  }
GRAPHQL

RSpec.describe Types::RecordingsExtension, type: :request do
  context 'when there are no recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { id: site.id, size: 15, page: 0 }
      graphql_request(site_recordings_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['recordings']
      expect(response['items']).to eq []
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 15,
          'pageCount' => 0
        }
      )
    end
  end

  context 'when there are several recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { id: site.id, size: 15, page: 0 }
      graphql_request(site_recordings_query, variables, user)
    end

    before do
      create_es_recordings(site: site, count: 5)
    end

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 15,
          'pageCount' => 1
        }
      )
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:cursor) { nil }

    before do
      create_es_recordings(site: site, count: 15)

      variables = { id: site.id, size: 10, page: 0 }
      graphql_request(site_recordings_query, variables, user)
    end

    subject do
      variables = { id: site.id, size: 10, page: 1 }
      graphql_request(site_recordings_query, variables, user)
    end

    it 'returns the second set of results' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 10,
          'pageCount' => 2
        }
      )
    end
  end
end
