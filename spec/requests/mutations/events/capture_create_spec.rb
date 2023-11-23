# frozen_string_literal: true

require 'rails_helper'

event_capture_create_mutation = <<-GRAPHQL
  mutation($input: EventCaptureCreateInput!) {
    eventCaptureCreate(input: $input) {
      name
      type
      rules {
        condition
        matcher
        value
      }
      count
      lastCountedAt {
        iso8601
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::CaptureCreate, type: :request do
  context 'when assigning no groups' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before do
      allow(EventsProcessingJob).to receive(:perform_later)
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          type: EventCapture::PAGE_VISIT,
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
      graphql_request(event_capture_create_mutation, variables, user)
    end

    it 'returns the event' do
      event = subject['data']['eventCaptureCreate']
      expect(event).to eq(
        'name' => 'My event',
        'type' => 0,
        'rules' => [
          {
            'value' => '/test',
            'matcher' => 'equals',
            'condition' => 'or'
          }
        ],
        'count' => 0,
        'lastCountedAt' => nil
      )
    end

    it 'creates the record' do
      expect { subject }.to change { site.reload.event_captures.size }.from(0).to(1)
    end

    it 'kicks off a job to fetch the counts' do
      subject
      expect(EventsProcessingJob).to have_received(:perform_later)
    end
  end
end
