# frozen_string_literal: true

require 'rails_helper'

site_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      id
      name
      url
      ownerName
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
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Site, type: :request do
  context 'when there is no current_user' do
    let(:site) { create(:site) }

    it 'raises an error' do
      response = graphql_request(site_query, { site_id: site.id }, nil)

      expect(response['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the site does not exist' do
    let(:user) { create(:user) }

    it 'returns nil' do
      response = graphql_request(site_query, { site_id: 12938912 }, user)

      expect(response['data']['site']).to be_nil
    end
  end

  context 'when the site does exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    it 'returns the site' do
      response = graphql_request(site_query, { site_id: site.id }, user)

      expect(response['data']['site']).to eq(
        {
          'id' => site.id.to_s,
          'name' => site.name,
          'url' => site.url,
          'ownerName' => "#{user.first_name} #{user.last_name}",
          'plan' => {
            'planId' => site.plan.plan_id,
            'name' => site.plan.name
          },
          'uuid' => site.uuid,
          'verifiedAt' => {
            'iso8601' => site.verified_at.iso8601
          },
          'team' => [
            {
              'id' => site.team[0].id.to_s,
              'role' => site.team[0].role,
              'status' => site.team[0].status,
              'user' => {
                'id' => user.id.to_s,
                'firstName' => user.first_name,
                'lastName' => user.last_name
              }
            }
          ]
        }
      )
    end
  end

  context 'when the user is in a pending state' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    before do
      create(:team, user: user, site: site, role: Team::MEMBER, status: Team::PENDING)
    end

    it 'does not return the site' do
      response = graphql_request(site_query, { site_id: site.id }, user)

      expect(response['data']['site']).to be_nil
    end
  end

  context 'when the user is not authorized' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    it 'does not return the site' do
      response = graphql_request(site_query, { site_id: site.id }, user)

      expect(response['data']['site']).to be_nil
    end
  end

  context 'when the user is not authorized but they are a superuser' do
    context 'and the site allows superuser access' do
      let(:user) { create(:user, superuser: true) }
      let(:site) { create(:site_with_team, superuser_access_enabled: true) }

      it 'returns the site' do
        response = graphql_request(site_query, { site_id: site.id }, user)

        expect(response['data']['site']).not_to be_nil
      end
    end

    context 'and the site does not allow superuser access' do
      let(:user) { create(:user, superuser: true) }
      let(:site) { create(:site_with_team, superuser_access_enabled: false) }

      it 'returns the site' do
        response = graphql_request(site_query, { site_id: site.id }, user)

        expect(response['data']['site']).to be_nil
      end
    end
  end
end
