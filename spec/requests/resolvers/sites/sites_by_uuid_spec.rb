# typed: false
# frozen_string_literal: true

require 'rails_helper'

site_by_uuid_query = <<-GRAPHQL
  query($site_id: ID!) {
    siteByUuid(siteId: $site_id) {
      id
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::SiteByUuid, type: :request do
  context 'when there is no current_user' do
    let(:site) { create(:site) }

    it 'returns nil' do
      response = graphql_request(site_by_uuid_query, { site_id: site.uuid }, nil)

      expect(response['data']['siteByUuid']).to be_nil
    end
  end

  context 'when the site does not exist' do
    let(:user) { create(:user) }

    it 'returns nil' do
      response = graphql_request(site_by_uuid_query, { site_id: SecureRandom.uuid }, user)

      expect(response['data']['siteByUuid']).to be_nil
    end
  end

  context 'when the site does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    it 'returns the site' do
      response = graphql_request(site_by_uuid_query, { site_id: site.uuid }, user)

      expect(response['data']['siteByUuid']).to eq('id' => site.id.to_s)
    end
  end
end
