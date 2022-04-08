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
      sentimentEnabled
      sentimentAccentColor
      sentimentExcludedPages
      sentimentLayout
      sentimentDevices
    }
  }
GRAPHQL

RSpec.describe 'QueryFeedback', type: :request do
  context 'when the site has no feedback saved' do
    it 'does not return the feedback' do
      response = graphql_request(feedback_query, { site_id: SecureRandom.uuid }, nil)

      expect(response['data']['feedback']).to eq nil
    end
  end

  context 'when the site has feedback saved' do
    let(:site) { create(:site) }

    before do
      Feedback.create(
        site: site,
        nps_enabled: true,
        nps_accent_color: '#000',
        nps_schedule: '1_week',
        nps_phrase: 'Teapot',
        nps_follow_up_enabled: false,
        nps_contact_consent_enabled: false,
        nps_layout: 'bottom_left',
        sentiment_enabled: true,
        sentiment_accent_color: '#000',
        sentiment_excluded_pages: [],
        sentiment_layout: 'bottom_left',
        sentiment_devices: ['desktop', 'mobile']
      )
    end

    it 'returns the feedback' do
      response = graphql_request(feedback_query, { site_id: site.uuid }, nil)

      expect(response['data']['feedback']).to eq(
        'npsAccentColor' => '#000', 
        'npsContactConsentEnabled' => false, 
        'npsEnabled' => true, 
        'npsFollowUpEnabled' => false,
        'npsLayout' => 'bottom_left',
        'npsPhrase' => 'Teapot',
        'npsSchedule' => '1_week',
        'sentimentAccentColor' => '#000',
        'sentimentEnabled' => true, 
        'sentimentExcludedPages' => [], 
        'sentimentLayout' => 'bottom_left',
        'sentimentDevices' => ['desktop', 'mobile']
      )
    end
  end
end
