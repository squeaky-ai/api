# frozen_string_literal: true

require 'rails_helper'

admin_partner_create_mutation = <<-GRAPHQL
  mutation($input: AdminUserPartnerCreateInput!) {
    adminUserPartnerCreate(input: $input) {
      id
      partner {
        name
        slug
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::UserPartnerCreate, type: :request do
  context 'when the user is already a partner' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_become_partner) { create(:user) }
    let!(:partner) { create(:partner, user: user_to_become_partner) }

    subject do
      variables = {
        input: {
          id: user_to_become_partner.id,
          name: 'My Company',
          slug: 'my-company'
        }
      }
  
      graphql_request(admin_partner_create_mutation, variables, user)
    end

    it 'returns the unmodified user' do
      response = subject['data']['adminUserPartnerCreate']
      expect(response).to eq(
        'id' => user_to_become_partner.id.to_s,
        'partner' => {
          'name' => partner.name,
          'slug' => partner.slug
        }
      )
    end

    it 'does not create a partner' do
      expect { subject }.not_to change { Partner.all.size }
    end
  end

  context 'when the user is not a partner' do
    let(:user) { create(:user, superuser: true) }
    let(:user_to_become_partner) { create(:user) }

    subject do
      variables = {
        input: {
          id: user_to_become_partner.id,
          name: 'My Company',
          slug: 'my-company'
        }
      }
  
      graphql_request(admin_partner_create_mutation, variables, user)
    end

    it 'returns the user' do
      response = subject['data']['adminUserPartnerCreate']
      expect(response).to eq(
        'id' => user_to_become_partner.id.to_s,
        'partner' => {
          'name' => 'My Company',
          'slug' => 'my-company'
        }
      )
    end

    it 'does creates a partner' do
      expect { subject }.to change { Partner.all.size }.by(1)
    end

    context 'when the partner slug is already taken' do
      let(:user) { create(:user, superuser: true) }
      let(:user_to_become_partner) { create(:user) }
      let!(:partner) { create(:partner, slug: 'my-company', user: create(:user)) }
  
      subject do
        variables = {
          input: {
            id: user_to_become_partner.id,
            name: 'My Company',
            slug: 'my-company'
          }
        }
    
        graphql_request(admin_partner_create_mutation, variables, user)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'Slug This site is already registered'
      end
    end
  end
end
