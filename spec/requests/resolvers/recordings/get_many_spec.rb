# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($site_id: ID!, $size: Int, $page: Int, $sort: RecordingsSort, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      recordings(size: $size, page: $page, sort: $sort, fromDate: $from_date, toDate: $to_date) {
        items {
          id
          siteId
          language
          duration
          pageViews
          pageCount
          startPage
          exitPage
          device {
            browserName
            browserDetails
            viewportX
            viewportY
            deviceX
            deviceY
            deviceType
            useragent
          }
          visitor {
            id
            visitorId
          }
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

RSpec.describe Resolvers::Recordings::GetMany, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.current.strftime('%Y-%m-%d')

      variables = {
        site_id: site.id,
        size: 15,
        page: 0,
        from_date: today,
        to_date: today
      }
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
          'sort' => 'connected_at__desc'
        }
      )
    end
  end

  context 'when there are several recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.current.strftime('%Y-%m-%d')

      variables = {
        site_id: site.id,
        size: 15,
        page: 0,
        from_date: today,
        to_date: today
      }

      graphql_request(site_recordings_query, variables, user)
    end

    before { 5.times.map { create(:recording, site:) } }

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
          'sort' => 'connected_at__desc'
        }
      )
    end
  end

  context 'when a recording is analytics only' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.current.strftime('%Y-%m-%d')

      variables = {
        site_id: site.id,
        size: 15,
        page: 0,
        from_date: today,
        to_date: today
      }

      graphql_request(site_recordings_query, variables, user)
    end

    before do
      5.times.map { create(:recording, site:) }
      create(:recording, status: Recording::ANALYTICS_ONLY, site:)
    end

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end
  end

  context 'when paginating' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before { 15.times.map { create(:recording, site:) } }

    subject do
      today = Time.current.strftime('%Y-%m-%d')

      variables = {
        site_id: site.id,
        size: 10,
        page: 2,
        from_date: today,
        to_date: today
      }

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
          'sort' => 'connected_at__desc'
        }
      )
    end
  end

  context 'when sorting results' do
    context 'when sorting by descending' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        today = Time.current.strftime('%Y-%m-%d')

        variables = {
          site_id: site.id,
          size: 5,
          page: 0,
          sort: 'connected_at__desc',
          from_date: today,
          to_date: today
        }

        graphql_request(site_recordings_query, variables, user)
      end

      before { 5.times.map { create(:recording, site:) } }

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
            'sort' => 'connected_at__desc'
          }
        )
      end
    end

    context 'when sorting by ascending' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        today = Time.current.strftime('%Y-%m-%d')

        variables = {
          site_id: site.id,
          size: 5,
          page: 0,
          sort: 'connected_at__asc',
          from_date: today,
          to_date: today
        }

        graphql_request(site_recordings_query, variables, user)
      end

      before { 5.times.map { create(:recording, site:) } }

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
            'sort' => 'connected_at__asc'
          }
        )
      end
    end
  end
end
