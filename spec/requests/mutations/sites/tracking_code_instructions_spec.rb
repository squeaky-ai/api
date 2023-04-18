# frozen_string_literal: true

require 'rails_helper'

site_tracking_code_instructions_mutation = <<-GRAPHQL
  mutation TrackingCodeInstructions($input: SitesTrackingCodeInstructionsInput!) {
    trackingCodeInstructions(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Sites::TrackingCodeInstructions, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  subject do
    variables = {
      input: { 
        siteId: site.id, 
        firstName: 'Bob',
        email: 'bob@developer.com'
      }
    }
    graphql_request(site_tracking_code_instructions_mutation, variables, user)
  end

  it 'sends an email' do
    expect { subject }.to change { ActionMailer::Base.deliveries.size }.by(1)
  end
end
