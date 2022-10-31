# frozen_string_literal: true

require 'rails_helper'

visitors_export_query = <<-GRAPHQL
  query GetVisitorExport($site_id: ID!, $visitor_id: ID!) {
    site(siteId: $site_id) {
      id
      visitor(visitorId: $visitor_id) {
        export {
          recordingsCount
          npsFeedback {
            score
            comment
            contact
            email
          }
          sentimentFeedback {
            score
            comment
          }
          linkedData
        }
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Visitors::Export, type: :request do
  let(:user) { create(:user) }
  let(:site) { create(:site_with_team, owner: user) }
  let(:visitor) { create(:visitor, site_id: site.id, external_attributes: { email: 'sfsdf@gmail.com' }) }

  before do  
    recording_1 = create(:recording, site: site, visitor: visitor)
    recording_2 = create(:recording, site: site, visitor: visitor)
    recording_3 = create(:recording, site: site, visitor: visitor)
    recording_4 = create(:recording, site: site, visitor: visitor)
    recording_5 = create(:recording, site: site, visitor: visitor)

    create(:nps, recording: recording_1)
    create(:nps, recording: recording_2)
    create(:sentiment, recording: recording_3)
    create(:sentiment, recording: recording_4)
  end

  subject do
    variables = { site_id: site.id, visitor_id: visitor.id }
    graphql_request(visitors_export_query, variables, user)
  end

  it 'returns the data' do
    response = subject['data']['site']['visitor']['export']
    expect(response).to eq(
      'recordingsCount' => 5,
      'npsFeedback' => [
        {
          'comment' => nil,
          'contact' => false,
          'email' => nil,
          'score' => 5
        }, 
        {
          'comment' => nil,
          'contact' => false,
          'email' => nil, 
          'score' => 5
        }
      ],
      'sentimentFeedback' => [
        {
          'comment' => nil,
          'score' => 5
        }, 
        {
          'comment' => nil,
          'score' => 5
        }
      ],
      'linkedData' => '{"email":"sfsdf@gmail.com"}'
    )
  end
end
