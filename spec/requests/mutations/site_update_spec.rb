# frozen_string_literal: true

require 'rails_helper'

site_update_mutation = <<-GRAPHQL
  mutation($site_id: ID!, $name: String, $url: String) {
    siteUpdate(input: { siteId: $site_id, name: $name, url: $url }) {
      id
      name
      url
    }
  }
GRAPHQL

RSpec.describe Mutations::SiteUpdate, type: :request do
  context 'when updating the url' do
    context 'when a site with this url already exists' do
      let(:url) { Faker::Internet.url }
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id, url: url }
        graphql_request(site_update_mutation, variables, user)
      end

      before { create_site(url: Site.format_uri(url)) }

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'Url This site is already registered'
      end
    end

    context 'when the url is invalid' do
      let(:url) { 'fdsdfgdfgdfgdfg' }
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id, url: url }
        graphql_request(site_update_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is valid' do
      let(:url) { Faker::Internet.url }
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject do
        variables = { site_id: site.id, url: url }
        graphql_request(site_update_mutation, variables, user)
      end

      it 'returns the updated site' do
        expect(url).to start_with subject['data']['siteUpdate']['url']
      end

      it 'updates the record' do
        subject
        expect(url).to start_with site.reload.url
      end
    end
  end

  context 'when updating the name' do
    let(:name) { Faker::Company.name }
    let(:user) { create_user }
    let(:site) { create_site_and_team(user: user) }

    subject do
      variables = { site_id: site.id, name: name }
      graphql_request(site_update_mutation, variables, user)
    end

    it 'returns the updated site' do
      expect(name).to eq subject['data']['siteUpdate']['name']
    end

    it 'updates the record' do
      subject
      expect(site.reload.name).to eq name
    end
  end
end
