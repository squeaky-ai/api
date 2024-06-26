# frozen_string_literal: true

require 'rails_helper'

analytics_visitors_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        visitorsCount {
          total
          new
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::VisitorsCount, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['total']).to eq 0
    end

    it 'returns the number of new visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['new']).to eq 0
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor, created_at: Time.new(2021, 8, 7).utc, site_id: site.id)
      create(:visitor, created_at: Time.new(2021, 8, 6).utc, site_id: site.id)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['total']).to eq 2
    end

    it 'returns the number of new visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['new']).to eq 2
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      create(:visitor, created_at: Time.new(2021, 8, 7).utc, site_id: site.id)
      create(:visitor, created_at: Time.new(2021, 8, 6).utc, site_id: site.id)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique visitor' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['total']).to eq 2
    end

    it 'returns the number of new visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['new']).to eq 2
    end
  end

  context 'when the visitor has been viewed' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor, created_at: Time.new(2021, 8, 7).utc, site_id: site.id)

      visitor.update(new: false)
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_visitors_query, variables, user)
    end

    it 'returns the number of unique visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['total']).to eq 1
    end

    it 'returns the number of new visitors' do
      response = subject['data']['site']['analytics']
      expect(response['visitorsCount']['new']).to eq 0
    end
  end
end
