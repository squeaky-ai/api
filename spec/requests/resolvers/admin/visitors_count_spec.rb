# typed: false
# frozen_string_literal: true

require 'rails_helper'

visitors_count_admin_query = <<-GRAPHQL
  query {
    admin {
      visitorsCount
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::VisitorsCount, type: :request do
  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      response = graphql_request(visitors_count_admin_query, {}, user)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      Visitor.destroy_all

      create(:visitor)
      create(:visitor)
      create(:visitor)
    end

    it 'returns the count' do
      response = graphql_request(visitors_count_admin_query, {}, user)

      expect(response['data']['admin']['visitorsCount']).to eq 3
    end
  end
end
