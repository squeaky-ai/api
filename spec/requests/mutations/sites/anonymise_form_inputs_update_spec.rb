# frozen_string_literal: true

require 'rails_helper'

site_anonymise_form_inputs_update_mutation = <<-GRAPHQL
  mutation($input: AnonymiseFormInputsUpdateInput!) {
    anonymiseFormInputsUpdate(input: $input) {
      anonymiseFormInputs
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::AnonymiseFormInputsUpdate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      input: {
        siteId: site.id, 
        enabled: false
      }
    }

    graphql_request(site_anonymise_form_inputs_update_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.anonymise_form_inputs }.from(true).to(false)
  end

  it 'returns the updated value' do
    response = subject['data']['anonymiseFormInputsUpdate']['anonymiseFormInputs']
    expect(response).to eq false
  end
end
