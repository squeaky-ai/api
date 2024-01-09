# frozen_string_literal: true

require 'rails_helper'

admin_user_update_mutation = <<-GRAPHQL
  mutation($input: AdminUserUpdateInput!) {
    adminUserUpdate(input: $input) {
      id
      providerCommsEmail
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::UserUpdate, type: :request do
  let(:user) { create(:user, superuser: true) }
  let(:user_to_update) { create(:user) }

  subject do
    variables = {
      input: {
        id: user_to_update.id,
        providerCommsEmail: 'foo@bar.com'
      }
    }

    graphql_request(admin_user_update_mutation, variables, user)
  end

  it 'updates the user' do
    expect { subject }.to change { user_to_update.reload.provider_comms_email }.from(nil).to('foo@bar.com')
  end
end
