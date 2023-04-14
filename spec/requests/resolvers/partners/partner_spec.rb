# typed: false
# frozen_string_literal: true

require 'rails_helper'

partner_query = <<-GRAPHQL
  query GetPartner($slug: String!) {
    partner(slug: $slug)
  }
GRAPHQL

RSpec.describe Resolvers::Partners::Partner, type: :request do
  context 'when the partner does not exist' do
    subject do
      variables = { slug: 'sdfsfdsfsdf' }
      graphql_request(partner_query, variables, nil)
    end

    it 'returns nil' do
      expect(subject['data']['partner']).to eq(nil)
    end
  end

  context 'when the partner does exist' do
    let(:partner) { create(:partner, user: create(:user)) }

    subject do
      variables = { slug: partner.slug }
      graphql_request(partner_query, variables, nil)
    end

    it 'returns the name' do
      expect(subject['data']['partner']).to eq(partner.name)
    end
  end
end
