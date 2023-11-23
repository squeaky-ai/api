# frozen_string_literal: true

require 'rails_helper'

site_update_mutation = <<-GRAPHQL
  mutation($input: SitesUpdateInput!) {
    siteUpdate(input: $input) {
      id
      name
      url
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::Update, type: :request do
  context 'when updating the url' do
    context 'when a site with this url already exists' do
      let(:url) { 'https://google.com' }
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          input: {
            siteId: site.id,
            url:
          }
        }
        graphql_request(site_update_mutation, variables, user)
      end

      before { create(:site, url: Site.format_uri(url)) }

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'Url This site is already registered'
      end
    end

    context 'when the url is localhost' do
      let(:url) { 'http://localhost:3000' }
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          input: {
            siteId: site.id,
            url:
          }
        }
        graphql_request(site_update_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is invalid' do
      let(:url) { 'fdsdfgdfgdfgdfg' }
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          input: {
            siteId: site.id,
            url:
          }
        }
        graphql_request(site_update_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'The provided uri is not valid'
      end
    end

    context 'when the url is valid' do
      let(:url) { 'https://thedoors.com' }
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject do
        variables = {
          input: {
            siteId: site.id,
            url:
          }
        }
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
    let(:name) { 'Sausage' }
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          name:
        }
      }
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
