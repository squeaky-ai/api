# typed: false
# frozen_string_literal: true

require 'rails_helper'

event_group_create_mutation = <<-GRAPHQL
  mutation($input: EventGroupCreateInput!) {
    eventGroupCreate(input: $input) {
      id
      name
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::GroupCreate, type: :request do
  context 'when the group does not exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:name) { 'Carpet' }

    subject do
      variables = {
        input: {
          siteId: site.id, 
          name:
        }
      }
      graphql_request(event_group_create_mutation, variables, user)
    end

    it 'returns the created group' do
      group = subject['data']['eventGroupCreate']
      expect(group['name']).to eq name
    end

    it 'creates the record' do
      expect { subject }.to change { site.reload.event_groups.size }.from(0).to(1)
    end
  end

  context 'when a group with that name exists already' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:name) { 'Plant' }

    before do
      site.event_groups << EventGroup.new(name: name, site_id: site.id)
      site.save
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          name:
        }
      }
      graphql_request(event_group_create_mutation, variables, user)
    end

    it 'returns the existing group' do
      group = subject['data']['eventGroupCreate']
      expect(group['name']).to eq name
    end

    it 'does note create the record' do
      expect { subject }.not_to change { site.reload.event_groups.size }
    end
  end
end
