# frozen_string_literal: true

require 'rails_helper'

feedback_query = <<-GRAPHQL
  query($site_id: String!) {
    feedback(siteId: $site_id) {
      npsEnabled
      npsAccentColor
      npsSchedule
      npsPhrase
      npsFollowUpEnabled
      npsContactConsentEnabled
      npsLayout
      npsExcludedPages
      sentimentEnabled
      sentimentAccentColor
      sentimentExcludedPages
      sentimentLayout
      sentimentDevices
    }
  }
GRAPHQL

RSpec.describe Resolvers::Feedback::Feedback, type: :request do
  context 'when the site has no feedback saved' do
    it 'does not return the feedback' do
      response = graphql_request(feedback_query, { site_id: SecureRandom.uuid }, nil)

      expect(response['data']['feedback']).to eq nil
    end
  end

  context 'when the site has feedback saved' do
    let(:site) { create(:site) }

    before { create(:feedback, site:) }

    it 'returns the feedback' do
      response = graphql_request(feedback_query, { site_id: site.uuid }, nil)

      expect(response['data']['feedback']).to eq(
        'npsAccentColor' => '#0074E0', 
        'npsContactConsentEnabled' => false, 
        'npsEnabled' => false, 
        'npsFollowUpEnabled' => true,
        'npsLayout' => 'full_width',
        'npsPhrase' => 'My Feedback',
        'npsSchedule' => 'once',
        'npsExcludedPages' => [],
        'sentimentAccentColor' => '#0074E0',
        'sentimentEnabled' => false, 
        'sentimentExcludedPages' => [], 
        'sentimentLayout' => 'right_middle',
        'sentimentDevices' => ['desktop', 'tablet']
      )
    end
  end
end
