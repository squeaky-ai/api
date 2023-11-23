# frozen_string_literal: true

require 'rails_helper'

event_capture_delete_mutation = <<-GRAPHQL
  mutation($input: EventCaptureDeleteInput!) {
    eventCaptureDelete(input: $input) {
      id
    }
  }
GRAPHQL

RSpec.describe Mutations::Events::CaptureDelete, type: :request do
  context 'when the capture does not exist' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          eventId: 12312321312
        }
      }
      graphql_request(event_capture_delete_mutation, variables, user)
    end

    it 'returns nil' do
      event = subject['data']['eventCaptureDelete']
      expect(event).to eq(nil)
    end

    it 'does not delete anything' do
      expect { subject }.not_to(change { site.reload.event_captures.size })
    end
  end

  context 'when the capture exists' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let!(:event) { create(:event_capture, site:) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          eventId: event.id
        }
      }
      graphql_request(event_capture_delete_mutation, variables, user)
    end

    it 'returns nil' do
      event = subject['data']['eventCaptureDelete']
      expect(event).to eq(nil)
    end

    it 'deletes the capture' do
      expect { subject }.to change { site.reload.event_captures.size }.from(1).to(0)
    end
  end
end
