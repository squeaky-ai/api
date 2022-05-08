# frozen_string_literal: true

require 'rails_helper'

analytics_user_paths_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!, $page: String!, $position: PathPosition!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        userPaths(page: $page, position: $position) {
          path
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::UserPaths, type: :request do
  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      visitor = create(:visitor)

      recording_1 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', entered_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)
      create(:page, url: '/test', entered_at: Time.new(2021, 8, 7).to_i * 1000, recording: recording_1)

      recording_2 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/', entered_at: Time.new(2021, 8, 6).to_i * 1000, recording: recording_2)

      recording_3 = create(:recording, site: site, visitor: visitor)
      create(:page, url: '/test', entered_at: Time.new(2021, 8, 5).to_i * 1000, recording: recording_3)
      create(:page, url: '/test', entered_at: Time.new(2021, 8, 5).to_i * 1000, recording: recording_3)
    end

    context 'when using the start position' do
      subject do
        variables = { 
          site_id: site.id, 
          from_date: '2021-08-01', 
          to_date: '2021-08-08',
          page: '/',
          position: 'Start'
        }
        graphql_request(analytics_user_paths_query, variables, user)
      end
  
      it 'returns the paths that match' do
        paths = subject['data']['site']['analytics']['userPaths']
        expect(paths).to eq(
          [
            {
              'path' => ['/', '/test']
            },
            {
              'path' => ['/']
            }
          ]
        )
      end
    end
  
    context 'when using the end position' do
      subject do
        variables = { 
          site_id: site.id, 
          from_date: '2021-08-01', 
          to_date: '2021-08-08',
          page: '/test',
          position: 'End'
        }
        graphql_request(analytics_user_paths_query, variables, user)
      end
  
      it 'returns the paths that match' do
        paths = subject['data']['site']['analytics']['userPaths']
        expect(paths).to eq(
          [
            {
              'path' => ['/', '/test']
            },
            {
              'path' => ['/test', '/test']
            }
          ]
        )
      end
    end
  end
end
