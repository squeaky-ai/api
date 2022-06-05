# frozen_string_literal: true

require 'rails_helper'

event_capture_delete_bulk_mutation = <<-GRAPHQL
  mutation($input: EventCaptureDeleteBulkInput!) {
    eventCaptureDeleteBulk(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::CaptureDeleteBulk, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }

  let(:events) do
    [
      create(:event_capture, site:),
      create(:event_capture, site:),
      create(:event_capture, site:),
      create(:event_capture, site:)
    ]
  end

  before { events }

  subject do
    ids = events.map(&:id).map(&:to_s)

    variables = {
      input: {
        siteId: site.id, 
        eventIds: [*ids, '23424234']
      }
    }
    graphql_request(event_capture_delete_bulk_mutation, variables, user)
  end

  it 'returns an empty array' do
    event = subject['data']['eventCaptureDeleteBulk']
    expect(event).to eq([])
  end

  it 'deletes the captures' do
    expect { subject }.to change { site.reload.event_captures.size }.from(4).to(0)
  end
end
