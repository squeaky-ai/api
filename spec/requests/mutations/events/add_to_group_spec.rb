# typed: false
# frozen_string_literal: true

require 'rails_helper'

event_add_to_group_mutation = <<-GRAPHQL
  mutation($input: EventAddToGroupInput!) {
    eventAddToGroup(input: $input) {
      id
      groupNames
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::AddToGroup, type: :request do
  context 'when assigning no groups' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    let(:group_1) { create(:event_group, site:) }
    let(:group_2) { create(:event_group, site:) }

    let(:event_1) { create(:event_capture, site:) }
    let(:event_2) { create(:event_capture, site:) }
    let(:event_3) { create(:event_capture, site:, event_groups: [group_2]) }


    subject do
      variables = {
        input: {
          siteId: site.id, 
          groupIds: [group_1.id],
          eventIds: [event_1.id, event_2.id, event_3.id]
        }
      }
      graphql_request(event_add_to_group_mutation, variables, user)
    end

    it 'returns the update events' do
      event = subject['data']['eventAddToGroup']
      expect(event).to match_array (
        [
          {
            'id' => event_1.id.to_s,
            'groupNames' => [group_1.name]
          },
          {
            'id' => event_2.id.to_s,
            'groupNames' => [group_1.name]
          },
          {
            'id' => event_3.id.to_s,
            'groupNames' => [group_1.name, group_2.name]
          }
        ]
      )
    end

    it 'updates the records' do
      expect { subject }.to change { event_1.reload.group_names.size }.from(0).to(1)
                       .and change { event_2.reload.group_names.size }.from(0).to(1)
                       .and change { event_3.reload.group_names.size }.from(1).to(2)
    end
  end
end
