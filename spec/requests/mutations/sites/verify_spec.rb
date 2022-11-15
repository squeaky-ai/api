# frozen_string_literal: true

require 'rails_helper'

site_verify_mutation = <<-GRAPHQL
  mutation($input: SitesVerifyInput!) {
    siteVerify(input: $input) {
      id
      verifiedAt
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::Verify, type: :request do
  context 'when the tracking script can be found' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    
    let(:body) do
      body = <<-HTML
        <!-- Squeaky Tracking Code for #{site.name} -->
        <script>
          // ...
          const siteId = '#{site.uuid}';
          // ...
        </script>
      HTML
    end

    let(:response) { double(:response, body:) }

    before do
      allow(HTTParty).to receive(:get).and_return(response)
    end

    subject do
      variables = { 
        input: {
          siteId: site.id 
        }
      }
      graphql_request(site_verify_mutation, variables, user)
    end

    it 'returns the verifiedAt timestamp' do
      expect(subject['data']['siteVerify']['verifiedAt']).not_to be_nil
    end
  end

  context 'when the tracking script can not be found' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:response) { double(:response, body:) }

    subject do
      variables = { 
        input: {
          siteId: site.id 
        }
      }
      graphql_request(site_verify_mutation, variables, user)
    end

    before { allow(HTTParty).to receive(:get).and_return(response) }

    it 'returns nil' do
      expect(subject['data']['siteVerify']['verifiedAt']).to be_nil
    end
  end

  context 'when the tracking script was active, but now can not be found' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before { site.verify! }

    subject do
      variables = { 
        input: {
          siteId: site.id 
        }
      }
      graphql_request(site_verify_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['siteVerify']['verifiedAt']).to be_nil
    end
  end

  context 'when the http request fails' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { 
        input: {
          siteId: site.id 
        }
      }
      graphql_request(site_verify_mutation, variables, user)
    end

    before do
      allow(HTTParty).to receive(:get).and_raise(StandardError)
    end

    it 'returns nil' do
      expect(subject['data']['siteVerify']['verifiedAt']).to be_nil
    end
  end
end
