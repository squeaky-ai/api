# frozen_string_literal: true

require 'rails_helper'

site_anonymise_preferences_update_mutation = <<-GRAPHQL
  mutation($input: AnonymisePreferencesUpdateInput!) {
    anonymisePreferencesUpdate(input: $input) {
      anonymiseFormInputs
      anonymiseText
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::AnonymisePreferencesUpdate, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = { 
      input: {
        siteId: site.id, 
        textEnabled: true,
        formsEnabled: false
      }
    }

    graphql_request(site_anonymise_preferences_update_mutation, variables, user)
  end

  it 'updates the value' do
    expect { subject }.to change { site.reload.anonymise_form_inputs }.from(true).to(false)
                     .and change { site.anonymise_text }.from(false).to(true)
  end

  it 'returns the updated value' do
    response = subject['data']['anonymisePreferencesUpdate']
    expect(response).to eq(
      'anonymiseFormInputs' => false,
      'anonymiseText' => true
    )
  end
end
