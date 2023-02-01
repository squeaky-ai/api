# frozen_string_literal: true

require 'rails_helper'

visitors_query = <<-GRAPHQL
  query($site_id: ID!, $page: Int, $size: Int, $sort: VisitorsSort, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      visitors(page: $page, size: $size, sort: $sort, fromDate: $from_date, toDate: $to_date) {
        items {
          id
          recordingCount {
            total
            new
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
          countries {
            code
            name
          }
          linkedData
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

RSpec.describe Resolvers::Visitors::GetMany, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      today = Time.now.strftime('%Y-%m-%d')

      variables = {
        site_id: site.id, 
        from_date: today, 
        to_date: today
      }

      graphql_request(visitors_query, variables, user)
    end

    it 'returns no items' do
      response = subject['data']['site']['visitors']
      expect(response['items']).to eq []
    end
  end

  context 'when there are some visitors' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor, site_id: site.id, updated_at: Time.new(2021, 8, 8, 0, 0, 0, "+00:00"))
      create(:visitor, site_id: site.id, updated_at: Time.new(2021, 8, 8, 0, 0, 0, "+00:00"))
    end

    subject do
      variables = {
        site_id: site.id, 
        from_date: '2021-08-08', 
        to_date: '2021-08-08'
      }

      graphql_request(visitors_query, variables, user)
    end

    it 'returns the visitors' do
      response = subject['data']['site']['visitors']
      expect(response['items'].size).to eq 2
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['visitors']
      expect(response['pagination']).to eq(
        'pageSize' => 25,
        'total' => 2,
        'sort' => 'last_activity_at__desc'
      )
    end
  end

  context 'when there are no external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor, site_id: site.id, updated_at: Time.new(2021, 8, 8, 0, 0, 0, "+00:00"))
    end

    subject do
      variables = {
        site_id: site.id,
        from_date: '2021-08-08', 
        to_date: '2021-08-08'
      }

      graphql_request(visitors_query, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['linkedData']).to eq nil
    end
  end

  context 'when there are some external attributes' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:external_attributes) { { name: 'Bob Dylan', email: 'bobby_d@gmail.com' } }

    before do
      create(:visitor, site_id: site.id, external_attributes: external_attributes, updated_at: Time.new(2021, 8, 8, 0, 0, 0, "+00:00"))
    end

    subject do
      variables = {
        site_id: site.id, 
        from_date: '2021-08-08', 
        to_date: '2021-08-08'
      }

      graphql_request(visitors_query, variables, user)
    end

    it 'returns the attributes' do
      response = subject['data']['site']['visitors']
      expect(response['items'][0]['linkedData']).to eq external_attributes.to_json
    end
  end
end
