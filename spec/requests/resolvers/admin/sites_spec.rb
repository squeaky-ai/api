# frozen_string_literal: true

require 'rails_helper'

sites_admin_query = <<-GRAPHQL
  query {
    admin {
      sites {
        items {
          id
          name
          url
          plan {
            planId
            name
          }
          uuid
          verifiedAt {
            iso8601
          }
          team {
            id
            role
            status
            user {
              id
              firstName
              lastName
            }
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

RSpec.describe Resolvers::Admin::Sites, type: :request do
  subject { graphql_request(sites_admin_query, {}, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    let(:user) { create(:user, superuser: true) }

    before do
      create(:site)
      create(:site)
    end

    it 'returns all the sites' do
      response = subject['data']['admin']['sites']

      expect(response['items'].size).to eq 2
    end
  end
end
