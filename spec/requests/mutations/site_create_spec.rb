# frozen_string_literal: true

require 'rails_helper'

site_create_mutation = <<-GRAPHQL
  mutation($name: String!, $url: String!) {
    siteCreate(input: { name: $name, url: $url }) {
      id
      name
      url
      ownerName
      plan
      planName
      uuid
      verifiedAt
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

RSpec.describe Mutations::SiteCreate, type: :request do
  context 'when a site with this url already exists' do
    let(:url) { Faker::Internet.url }
    let(:user) { create_user }
    let(:subject) { graphql_request(site_create_mutation, { url: url, name: Faker::Company.name }, user) }

    before { create_site(url: Site.format_uri(url)) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Url This site is already registered'
    end
  end

  context 'when a site with this url does not exist' do
    context 'when the url is invalid' do
      let(:url) { 'sdfsjkldfjsdklfsd' }
      let(:user) { create_user }
      let(:subject) { graphql_request(site_create_mutation, { url: url, name: Faker::Company.name }, user) }

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is valid' do
      let(:url) { Faker::Internet.url }
      let(:name) { Faker::Company.name }
      let(:user) { create_user }
      let(:subject) { graphql_request(site_create_mutation, { url: url, name: name }, user) }

      after do
        site = subject['data']['siteCreate']
        Authorizer.find(site_id: site['uuid']).delete!
      end

      it 'returns the created site' do
        site = subject['data']['siteCreate']

        expect(site['id']).not_to be nil
        expect(name).to eq site['name']
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

      it 'creates the authorization record in dynamo' do
        site = subject['data']['siteCreate']
        item = Authorizer.find(site_id: site['uuid'])

        expect(item.site_id).to eq site['uuid']
        expect(item.active).to eq true
        expect(item.origin).to eq site['url']
        expect(item.updated_at).to be nil
        expect(item.created_at).not_to be nil
      end
    end
  end
end
