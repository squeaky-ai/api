# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($site_id: ID!, $size: Int, $page: Int, $sort: RecordingSort) {
    site(siteId: $site_id) {
      recordings(size: $size, page: $page, sort: $sort) {
        items {
          id
          siteId
          visitorId
          language
          duration
          pageViews
          pageCount
          startPage
          exitPage
          deviceType
          browser
          browserString
          viewportX
          viewportY
        }
        pagination {
          pageSize
          total
          sort
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
      variables = { site_id: site.id, size: 15, page: 1 }
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
          'total' => 0,
          'sort' => 'DATE_DESC'
        }
      )
    end
  end

  context 'when there are several recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, size: 15, page: 1 }
      graphql_request(site_recordings_query, variables, user)
    end

    before { create_recordings(site: site, visitor: create_visitor, count: 5) }

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'pageSize' => 15,
          'total' => 5,
          'sort' => 'DATE_DESC'
        }
      )
    end
  end

  context 'when a recording is soft deleted' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, size: 15, page: 1 }
      graphql_request(site_recordings_query, variables, user)
    end

    before do
      create_recordings(site: site, visitor: create_visitor, count: 5)
      create_recording({ deleted: true }, site: site, visitor: create_visitor)
    end

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before do
      create_recordings(site: site, visitor: create_visitor, count: 15)
    end

    subject do
      variables = { site_id: site.id, size: 10, page: 2 }
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
          'total' => 15,
          'sort' => 'DATE_DESC'
        }
      )
    end
  end

  context 'when sorting results' do
    context 'when sorting by descending' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id, size: 5, page: 1, sort: 'DATE_DESC' }
        graphql_request(site_recordings_query, variables, user)
      end

      before { create_recordings(site: site, visitor: create_visitor, count: 5) }

      it 'returns the items with the oldest first' do
        items = subject['data']['site']['recordings']['items']
        timestamps = items.map { |i| i['timestamp'].to_i }
        expect(timestamps).to eq timestamps.sort.reverse
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']).to eq(
          {
            'pageSize' => 5,
            'total' => 5,
            'sort' => 'DATE_DESC'
          }
        )
      end
    end

    context 'when sorting by ascending' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id, size: 5, page: 1, sort: 'DATE_ASC' }
        graphql_request(site_recordings_query, variables, user)
      end

      before { create_recordings(site: site, visitor: create_visitor, count: 5) }

      it 'returns the items with the newest first' do
        items = subject['data']['site']['recordings']['items']
        timestamps = items.map { |i| i['timestamp'].to_i }
        expect(timestamps).to eq timestamps.sort
      end

      it 'returns the correct pagination' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']).to eq(
          {
            'pageSize' => 5,
            'total' => 5,
            'sort' => 'DATE_ASC'
          }
        )
      end
    end
  end
end
