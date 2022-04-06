# frozen_string_literal: true

require 'rails_helper'

verified_admin_query = <<-GRAPHQL
  query {
    admin {
      verified {
        verified
        unverified
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::Verified, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(verified_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'whjen the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      now = Time.now

      create(:site, verified_at: nil)
      create(:site, verified_at: nil)
      create(:site, verified_at: nil)
      create(:site, verified_at: now - 10.days)
      create(:site, verified_at: now - 3.months)
      create(:site, verified_at: now - 1.year)
    end

    it 'returns the counts' do
      response = graphql_request(verified_admin_query, {}, user)

      expect(response['data']['admin']['verified']).to eq(
        'verified' => 3,
        'unverified' => 3
      )
    end
  end
end
