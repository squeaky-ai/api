# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

admin_referral_delete_mutation = <<-GRAPHQL
  mutation($input: AdminReferralDeleteInput!) {
    adminReferralDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::ReferralDelete, type: :request do
  context 'when the referral does not have a site' do
    let(:user) { create(:user, superuser: true) }
    let(:partner) { create(:partner, user: create(:user)) }
    let!(:referral) { create(:referral, partner:, site: nil) }

    subject do      
      variables = {
        input: {
          id: referral.id
        }
      }
  
      graphql_request(admin_referral_delete_mutation, variables, user)
    end

    it 'returns nil' do
      expect(subject['data']['adminReferralDelete']).to eq(nil)
    end
  
    it 'deletes the record' do
      subject
      expect { referral.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'when the referral has a site' do
    let(:user) { create(:user, superuser: true) }
    let(:partner) { create(:partner, user: create(:user)) }
    let(:referral) { create(:referral, partner:, site: create(:site)) }

    subject do
      variables = {
        input: {
          id: referral.id
        }
      }
  
      graphql_request(admin_referral_delete_mutation, variables, user)
    end

    it 'returns the referral' do
      expect(subject['data']['adminReferralDelete']).to eq(
        'id' => referral.id.to_s
      )
    end
  
    it 'does not delete the record' do
      expect { subject }.not_to change { referral.reload }
    end
  end
end
