# frozen_string_literal: true

require 'rails_helper'

site_create_mutation = <<-GRAPHQL
  mutation($input: SitesCreateInput!) {
    siteCreate(input: $input) {
      id
      name
      url
      siteType
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

RSpec.describe Mutations::Sites::Create, type: :request do
  context 'when a site with this url already exists' do
    let(:url) { 'https://google.com' }
    let(:user) { create(:user) }

    subject do
      variables = {
        input: { 
          url:, 
          name: 'Cowbell' 
        }
      }
      graphql_request(site_create_mutation, variables, user)
    end

    before { create(:site, url: Site.format_uri(url)) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Url This site is already registered'
    end
  end

  context 'when a site with this url does not exist' do 
    context 'when the url is invalid' do
      let(:url) { 'sdfsjkldfjsdklfsd' }
      let(:user) { create(:user) }

      subject do
        variables = {
          input: { 
            url:, 
            name: 'Arctic Monkeys' 
          }
        }
        graphql_request(site_create_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is localhost' do
      let(:url) { 'http://localhost:3000' }
      let(:user) { create(:user) }

      subject do
        variables = {
          input: { 
            url:, 
            name: 'Arctic Monkeys' 
          }
        }
        graphql_request(site_create_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is valid' do
      let(:url) { 'https://thedoors.com' }
      let(:name) { 'The Doors' }
      let(:user) { create(:user) }

      subject do
        variables = {
          input: { 
            url:, 
            name:
          }
        }
        graphql_request(site_create_mutation, variables, user)
      end

      it 'returns the created site' do
        site = subject['data']['siteCreate']

        expect(site['id']).not_to be nil
        expect(site['name']).to eq name
        expect(site['siteType']).to eq Site::WEBSITE
        expect(url).to start_with site['url']
      end

      it 'returns the user as the owner of the site' do
        team = subject['data']['siteCreate']['team']

        expect(team[0]['role']).to eq 2
        expect(team[0]['status']).to eq 0
        expect(team[0]['user']['firstName']).to eq user.first_name
        expect(team[0]['user']['lastName']).to eq user.last_name
      end

      it 'is unverified' do
        expect(subject['data']['siteCreate']['verifiedAt']).to be_nil
      end

      it 'generates a uuid' do
        expect(subject['data']['siteCreate']['uuid']).not_to be nil
      end

      it 'enqueues the tracking' do
        expect { subject }.to have_enqueued_job(EventTrackingJob)
      end

      context 'when a partner has referred the url' do
        let!(:partner) { create(:partner, user: create(:user)) }
        let!(:referral) { create(:referral, partner:, url:) }

        it 'updates the referral to include the site' do
          site = subject['data']['siteCreate']
          expect(referral.reload.site_id.to_s).to eq(site['id'])
        end
      end
    end
  end
end
