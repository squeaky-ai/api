# frozen_string_literal: true

require 'rails_helper'

site_verify_mutation = <<-GRAPHQL
  mutation($site_id: ID!) {
    siteVerify(input: { siteId: $site_id }) {
      id
      verifiedAt
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteVerify, type: :request do
  context 'when the tracking script can be found' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_verify_mutation, variables, user)
    end

    before do
      body = <<-HTML
        <!-- Squeaky Tracking Code for #{site.name} -->
        <script>
          // ...
          const siteId = '#{site.uuid}';
          // ...
        </script>
      HTML
      allow(Net::HTTP).to receive(:get).and_return(body)
    end

    it 'returns the verifiedAt timestamp' do
      expect(subject['data']['siteVerify']['verifiedAt']).not_to be nil
    end
  end

  context 'when the tracking script can not be found' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_verify_mutation, variables, user)
    end

    before { allow(Net::HTTP).to receive(:get).and_return('') }

    it 'returns nil' do
      expect(subject['data']['siteVerify']['verifiedAt']).to be_nil
    end
  end

  context 'when the tracking script was active, but now can not be found' do
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    before { site.verify! }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_verify_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['siteVerify']['verifiedAt']).to be_nil
    end
  end
end
