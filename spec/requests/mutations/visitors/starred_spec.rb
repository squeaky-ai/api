# frozen_string_literal: true

require 'rails_helper'

visitor_starred_mutation = <<-GRAPHQL
  mutation($input: VisitorsStarredInput!) {
    visitorStarred(input: $input) {
      id
      starred
    }
  }
GRAPHQL

RSpec.describe Mutations::Visitors::Starred, type: :request do
  context 'when the recording does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id, 
          visitorId: SecureRandom.base36, 
          starred: false 
        }
      }
      graphql_request(visitor_starred_mutation, variables, user)
    end

    it 'throws an error' do
      error = subject['errors'][0]['message']
      expect(error).to eq 'Visitor not found'
    end
  end

  context 'when the visitor does exist' do
    context 'and it is starred' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:visitor) { create(:visitor, site_id: site.id) }
      
      before { create(:recording, site: site, visitor: visitor) }

      subject do
        variables = { 
          input: {
            siteId: site.id, 
            visitorId: visitor.id, 
            starred: true 
          }
        }
        graphql_request(visitor_starred_mutation, variables, user)
      end

      it 'marks the visitor as starred' do
        response = subject['data']['visitorStarred']
        expect(response['starred']).to be true
      end

      it 'updates the visitor in the database' do
        expect { subject }.to change { Visitor.find_by(id: visitor.id).starred }.from(false).to(true)
      end
    end

    context 'and it is unstarred' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:visitor) { create(:visitor, starred: true, site_id: site.id) }
      
      before { create(:recording, site: site, visitor: visitor) }

      subject do
        variables = { 
          input: {
            siteId: site.id, 
            visitorId: visitor.id, 
            starred: false 
          }
        }
        graphql_request(visitor_starred_mutation, variables, user)
      end

      it 'marks the visitor as unstarred' do
        response = subject['data']['visitorStarred']
        expect(response['starred']).to be false
      end

      it 'updates the visitor in the database' do
        expect { subject }.to change { Visitor.find_by(id: visitor.id).starred }.from(true).to(false)
      end
    end
  end
end
