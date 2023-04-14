# typed: false
# frozen_string_literal: true

require 'rails_helper'

event_group_delete_mutation = <<-GRAPHQL
  mutation($input: EventGroupDeleteInput!) {
    eventGroupDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::GroupDelete, type: :request do
  context 'when the group does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id, 
          groupId: 12312321312
        }
      }
      graphql_request(event_group_delete_mutation, variables, user)
    end

    it 'returns nil' do
      event = subject['data']['eventGroupDelete']
      expect(event).to eq(nil)
    end

    it 'does not delete anything' do
      expect { subject }.not_to change { site.reload.event_groups.size }
    end
  end
  
  context 'when the group exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let!(:group) { create(:event_group, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id, 
          groupId: group.id
        }
      }
      graphql_request(event_group_delete_mutation, variables, user)
    end

    it 'returns nil' do
      event = subject['data']['eventGroupDelete']
      expect(event).to eq(nil)
    end

    it 'deletes the group' do
      expect { subject }.to change { site.reload.event_groups.size }.from(1).to(0)
    end
  end
end
