# frozen_string_literal: true

require 'rails_helper'

nps_create_mutation = <<-GRAPHQL
  mutation($input: NpsCreateInput!) {
    npsCreate(input: $input) {
      message
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::NpsCreate, type: :request do
  let(:site_id) { SecureRandom.uuid }
  let(:visitor_id) { SecureRandom.base36 }
  let(:session_id) { SecureRandom.base36 }

  let(:time_now) { Time.new(2022, 6, 29).utc }

  before do
    allow(Time).to receive(:current).and_return(time_now)
  end

  subject do
    variables = {
      input: {
        siteId: site_id,
        visitorId: visitor_id,
        sessionId: session_id,
        score: 5,
        comment: 'Looks alright',
        contact: true,
        email: 'mshadows@gmail.com'
      }
    }

    graphql_request(nps_create_mutation, variables, nil)
  end

  it 'returns the success message' do
    response = subject['data']['npsCreate']
    expect(response).to eq('message' => 'NPS score saved')
  end

  it 'adds the score to the redis list' do
    subject

    value = Cache.redis.lrange("events::#{site_id}::#{visitor_id}::#{session_id}", 0, 1)

    encoded_output = <<~TEXT
      eJwli0EKwyAURK9SZi2lLTUFVz1AL/FJJJH4VfQnJQTvXqWzGXhv5sRqDxiE
      VKCwk98szAk5UmutMJFQB2WM+U/GyGyDtM8nxrVcyGc3L4JugtDYjOTNKlgm
      59uMy0JT/Jb33MG1/VEVxLEtQpxg7oMenvr1uPXU+gPvjzAD
    TEXT

    expect(value.first).to eq(encoded_output)
  end
end
