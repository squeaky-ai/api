# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_utm_terms_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      utmTerms
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::UtmTerms, type: :request do
  context 'when there are no terms' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_terms_query, variables, user)
    end

    it 'returns no terms' do
      response = subject['data']['site']['utmTerms']
      expect(response).to eq []
    end
  end

  context 'when there are some terms' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_term: 'term_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_term: 'term_2'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_terms_query, variables, user)
    end

    it 'returns the terms' do
      response = subject['data']['site']['utmTerms']
      expect(response).to eq ['term_1', 'term_2']
    end
  end

  context 'when there are some duplicate terms' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:recordings) do
      [
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_term: 'term_1'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_term: 'term_2'
        },
        {
          uuid: SecureRandom.uuid,
          site_id: site.id,
          utm_term: 'term_1'
        }
      ]
    end

    before do
      ClickHouse::Recording.insert do |buffer|
        recordings.each { |recording| buffer << recording }
      end
    end

    subject do
      variables = { site_id: site.id }
      graphql_request(site_utm_terms_query, variables, user)
    end

    it 'returns them deduped' do
      response = subject['data']['site']['utmTerms']
      expect(response).to eq ['term_1', 'term_2']
    end
  end
end
