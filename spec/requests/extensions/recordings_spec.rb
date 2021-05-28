# frozen_string_literal: true

require 'rails_helper'

site_recordings_query = <<-GRAPHQL
  query($id: ID!, $first: Int, $cursor: String) {
    site(id: $id) {
      recordings(first: $first, cursor: $cursor) {
        items {
          id
          siteId
          viewerId
          active
          locale
          duration
          pageCount
          startPage
          exitPage
          useragent
          viewportX
          viewportY
        }
        pagination {
          cursor
          isLast
          pageSize
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
      variables = { id: site.id, first: 10 }
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
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end

  context 'when there are several recordings' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { id: site.id, first: 10 }
      graphql_request(site_recordings_query, variables, user)
    end

    before { @recordings = create_recordings(site: site, count: 5) }

    after { @recordings.each(&:delete!) }

    it 'returns the items' do
      response = subject['data']['site']['recordings']
      expect(response['items'].size).to eq 5
    end

    it 'returns the correct pagination' do
      response = subject['data']['site']['recordings']
      expect(response['pagination']).to eq(
        {
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end

  context 'when limiting the results' do
    context 'when the number is below the minimum' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before { @recording = create_recording(site: site) }

      after { @recording.delete! }

      subject do
        variables = { id: site.id, first: -1 }
        graphql_request(site_recordings_query, variables, user)
      end

      it 'raises it to the minimum' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']['pageSize']).to eq 1
      end
    end

    context 'when the number is above the maximum' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before { @recording = create_recording(site: site) }

      after { @recording.delete! }

      subject do
        variables = { id: site.id, first: 51 }
        graphql_request(site_recordings_query, variables, user)
      end

      it 'lowers it to the maximum' do
        response = subject['data']['site']['recordings']
        expect(response['pagination']['pageSize']).to eq 50
      end
    end
  end

  context 'when paginating' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }
    let(:cursor) { nil }

    before do
      @recordings = create_recordings(site: site, count: 15)

      variables = { id: site.id, first: 10, cursor: nil }
      response = graphql_request(site_recordings_query, variables, user)

      # Take the cursor from the first request and use it for
      # the second
      @cursor = response['data']['site']['recordings']['pagination']['cursor']
      response
    end

    after { @recordings.each(&:delete!) }

    subject do
      variables = { id: site.id, first: 10, cursor: @cursor }
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
          'cursor' => nil,
          'isLast' => true,
          'pageSize' => 10
        }
      )
    end
  end
end
