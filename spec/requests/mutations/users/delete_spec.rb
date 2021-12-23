# frozen_string_literal: true

require 'rails_helper'

user_delete_mutation = <<-GRAPHQL
  mutation {
    userDelete(input: {}) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Users::Delete, type: :request do
  let(:user) { create(:user) }

  before do
    stub = double
    allow(stub).to receive(:deliver_now)
    allow(UserMailer).to receive(:destroyed).and_return(stub)
  end

  subject do
    variables = {}
    graphql_request(user_delete_mutation, variables, user)
  end

  it 'returns nil' do
    expect(subject['data']['userDelete']).to be_nil
  end

  it 'deletes the record' do
    subject
    expect { user.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'sends the email' do
    subject
    expect(UserMailer).to have_received(:destroyed)
  end

  describe 'when the user is the owner of some sites' do
    let(:user) { create(:user) }

    before do
      create_site_and_team(user: user)
      create_site_and_team(user: user)
    end

    subject do
      variables = {}
      graphql_request(user_delete_mutation, variables, user)
    end

    it 'destroys all of those sites' do
      expect { subject }.to change { user.sites.size }.from(2).to(0)
    end
  end

  describe 'when the user is a member of a site' do
    let(:user) { create(:user) }
    let(:site) { create_site_and_team(user: create(:user)) }

    before { create_team(user: user, site: site, role: Team::MEMBER) }

    subject do
      variables = {}
      graphql_request(user_delete_mutation, variables, user)
    end

    it 'destroys the team record' do
      expect { subject }.to change { site.team.size }.from(2).to(1)
    end

    it 'does not destroy the site' do
      expect { subject }.not_to change { Site.exists?(site.id) }
    end
  end
end
