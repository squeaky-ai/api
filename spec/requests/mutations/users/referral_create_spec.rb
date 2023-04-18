# typed: false
# frozen_string_literal: true

require 'rails_helper'

user_referral_create_mutation = <<-GRAPHQL
  mutation($input: UsersReferralCreateInput!) {
    userReferralCreate(input: $input) {
      url
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::ReferralCreate, type: :request do
  context 'when the user is not a partner' do
    let(:user) { create(:user) }

    subject do
      variables = { 
        input: {
          url: 'https://foo.co.uk'
        }
      }
      graphql_request(user_referral_create_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['userReferralCreate']).to eq(nil)
    end
  end

  context 'when the user is a partner' do
    let(:user) { create(:user) }
    let!(:partner) { create(:partner, user:) }

    subject do
      variables = { 
        input: {
          url: 'https://foo.co.uk'
        }
      }
      graphql_request(user_referral_create_mutation, variables, user)
    end

    it 'creates the referral' do
      expect(subject['data']['userReferralCreate']).to eq(
        'url' => 'https://foo.co.uk'
      )
    end

    context 'when the url is taken' do
      before do
        create(:referral, url: 'https://foo.co.uk', partner:)
      end

      it 'raises an error' do
        expect(subject['errors'][0]['message']).to eq 'Url This site is already registered'
      end
    end
  end
end
