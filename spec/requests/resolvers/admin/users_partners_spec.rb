# frozen_string_literal: true

require 'rails_helper'

users_partners_admin_query = <<-GRAPHQL
  query {
    admin {
      usersPartners {
        id
        firstName
        lastName
        email
        partner {
          name
          slug
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Admin::UsersPartners, type: :request do
  subject { graphql_request(users_partners_admin_query, {}, user) }

  context 'when the user is not a superuser' do
    let(:user) { create(:user) }

    it 'raises an error' do
      expect(subject['errors'][0]['message']).to eq 'Unauthorized'
    end
  end

  context 'when the user is a superuser' do
    context 'and there are no partners' do
      let(:user) { create(:user, superuser: true) }

      it 'returns an empty array' do
        response = subject['data']['admin']['usersPartners']
        expect(response).to eq([])
      end
    end

    context 'and there are partners' do
      let(:user) { create(:user, superuser: true) }
      let!(:partner_user) { create(:user) }
      let!(:partner) { create(:partner, user: partner_user) }

      before do
        # Some others that are not partners
        create(:user)
        create(:user)
      end

      it 'returns an empty array' do
        response = subject['data']['admin']['usersPartners']
        expect(response).to eq([
          {
            'id' => partner_user.id.to_s,
            'firstName' => partner_user.first_name,
            'lastName' => partner_user.last_name,
            'email' => partner_user.email,
            'partner' => {
              'name' => partner.name,
              'slug' => partner.slug
            }
          }
        ])
      end
    end
  end
end
