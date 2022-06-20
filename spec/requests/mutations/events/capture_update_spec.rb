# frozen_string_literal: true

require 'rails_helper'

event_capture_update_mutation = <<-GRAPHQL
  mutation($input: EventCaptureUpdateInput!) {
    eventCaptureUpdate(input: $input) {
      id
      name
      type
      rules {
        condition
        matcher
        value
      }
      count
      lastCountedAt
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::CaptureUpdate, type: :request do
  context 'when the capture does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id, 
          eventId: 12312321312,
          name: 'My event',
          rules: [
            {
              value: '/test',
              matcher: 'equals',
              condition: 'or'
            }
          ],
          groupIds: []
        }
      }
      graphql_request(event_capture_update_mutation, variables, user)
    end

    it 'returns nil' do
      event = subject['data']['eventCaptureUpdate']
      expect(event).to eq(nil)
    end
  end
  
  context 'when the capture exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:last_counted_at) { Time.new(2022, 01, 01) }
    let!(:event) { create(:event_capture, site:, name: 'Old Name', count: 5, last_counted_at:) }

    subject do
      variables = {
        input: {
          siteId: site.id, 
          eventId: event.id,
          name: 'New Name',
          rules: [
            {
              value: '/test',
              matcher: 'equals',
              condition: 'or'
            }
          ],
          groupIds: []
        }
      }
      graphql_request(event_capture_update_mutation, variables, user)
    end

    it 'returns nil' do
      response = subject['data']['eventCaptureUpdate']

      expect(response).to eq(
        'id' => event.id.to_s,
        'type' => event.type,
        'name' => 'New Name',
        'count' => 0,
        'lastCountedAt' => nil,
        'rules' => [{ 'value' => '/test', 'matcher' => 'equals', 'condition' => 'or' }]
      )
    end

    it 'updates the capture' do
      expect { subject }.to change { event.reload.name }.from('Old Name').to('New Name')
                       .and change { event.count }.from(5).to(0)
                       .and change { event.last_counted_at }.from(last_counted_at).to(nil)
                       .and change { event.rules }.from([]).to([{ 'value' => '/test', 'matcher' => 'equals', 'condition' => 'or' }])
    end
  end
end
