# frozen_string_literal: true

require 'rails_helper'

admin_site_delete_mutation = <<-GRAPHQL
  mutation($input: AdminSiteDeleteInput!) {
    adminSiteDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Admin::SiteDelete, type: :request do
  let!(:user) { create(:user, superuser: true) }
  let(:site) { create(:site_with_team, owner: user) }

  let!(:recording_1) { create(:recording, site:) }
  let!(:recording_2) { create(:recording, site:) }

  before do
    create(:team, site:, role: Team::MEMBER)
    create(:team, site:, role: Team::ADMIN)
    create(:team, site:, role: Team::OWNER)
  end

  subject do
    variables = {
      input: {
        id: site.id
      }
    }

    graphql_request(admin_site_delete_mutation, variables, user)
  end

  it 'returns nil' do
    expect(subject['data']['adminSiteDelete']).to be_nil
  end

  it 'deletes the record' do
    subject
    expect { site.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'does not delete the users' do
    expect { subject }.not_to change { User.count }
  end

  it 'kicks off some jobs to clean up the recordings' do
    subject
    expect(RecordingDeleteJob).to have_been_enqueued.once.with(match_array([recording_1.id, recording_2.id]))
  end
end
