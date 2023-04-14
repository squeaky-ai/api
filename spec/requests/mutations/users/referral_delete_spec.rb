# typed: false
# frozen_string_literal: true

require 'rails_helper'

user_referral_delete_mutation = <<-GRAPHQL
  mutation($input: UsersReferralDeleteInput!) {
    userReferralDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::ReferralDelete, type: :request do
  context 'when the referral does not have a site' do
    let(:user) { create(:user, superuser: true) }
    let(:partner) { create(:partner, user:) }
    let!(:referral) { create(:referral, partner:, site: nil) }

    subject do      
      variables = {
        input: {
          id: referral.id
        }
      }
  
      graphql_request(user_referral_delete_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['userReferralDelete']).to eq(nil)
    end
  
    it 'deletes the record' do
      subject
      expect { referral.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the referral has a site' do
    let(:user) { create(:user, superuser: true) }
    let(:partner) { create(:partner, user:) }
    let(:referral) { create(:referral, partner:, site: create(:site)) }

    subject do
      variables = {
        input: {
          id: referral.id
        }
      }
  
      graphql_request(user_referral_delete_mutation, variables, user)
    end

    it 'returns the referral' do
      expect(subject['data']['userReferralDelete']).to eq(
        'id' => referral.id.to_s
      )
    end
  
    it 'does not delete the record' do
      expect { subject }.not_to change { referral.reload }
    end
  end
end
