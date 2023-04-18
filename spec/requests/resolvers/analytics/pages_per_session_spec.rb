# typed: false
# frozen_string_literal: true

require 'rails_helper'

analytics_pages_per_session_query = <<-GRAPHQL
  query($site_id: ID!, $from_date: ISO8601Date!, $to_date: ISO8601Date!) {
    site(siteId: $site_id) {
      analytics(fromDate: $from_date, toDate: $to_date) {
        pagesPerSession {
          average
          trend
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Analytics::PagesPerSession, type: :request do
  context 'when there are no recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_per_session_query, variables, user)
    end

    it 'returns 0' do
      response = subject['data']['site']['analytics']
      expect(response['pagesPerSession']).to eq ({ 'average' => 0, 'trend' => 0 })
    end
  end

  context 'when there are some recordings' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: Time.new(2021, 8, 7).to_i * 1000,
          url: '/',
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: Time.new(2021, 8, 6).to_i * 1000,
          url: '/',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: Time.new(2021, 8, 6).to_i * 1000,
          url: '/test',
          recording_id: recording_2.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_per_session_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['pagesPerSession']).to eq ({ 'average' => 1.5, 'trend' => 1.5 })
    end
  end

  context 'when there are some recordings from the previous range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }
    let(:recording_4) { create(:recording, site:) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1628405639578,
          url: '/',
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1628405638578,
          url: '/',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1628405638578,
          url: '/test',
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1627800839578,
          url: '/',
          recording_id: recording_3.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1627800837578,
          url: '/',
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1627800837578,
          url: '/test',
          recording_id: recording_4.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          exited_at: 1627800837578,
          url: '/foo',
          recording_id: recording_4.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_per_session_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['pagesPerSession']).to eq({ 'average' => 1.75, 'trend' => -0.25 })
    end
  end

  context 'when some of the recordings are out of the date range' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording_1) { create(:recording, site:) }
    let(:recording_2) { create(:recording, site:) }
    let(:recording_3) { create(:recording, site:) }

    let(:pages) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 7).to_i * 1000,
          recording_id: recording_1.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/',
          exited_at: Time.new(2021, 8, 6).to_i * 1000,
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/test',
          exited_at: Time.new(2021, 8, 6).to_i * 1000,
          recording_id: recording_2.id
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          url: '/contact',
          exited_at: Time.new(2021, 7, 6).to_i * 1000,
          recording_id: recording_3.id
        }
      ]
    end

    before do
      ClickHouse::PageEvent.insert do |buffer|
        pages.each { |page| buffer << page }
      end
    end

    subject do
      variables = { site_id: site.id, from_date: '2021-08-01', to_date: '2021-08-08' }
      graphql_request(analytics_pages_per_session_query, variables, user)
    end

    it 'returns the average number of views' do
      response = subject['data']['site']['analytics']
      expect(response['pagesPerSession']).to eq({ 'average' => 1.5, 'trend' => 1.5 })
    end
  end
end
