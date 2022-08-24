# frozen_string_literal: true

require 'rails_helper'

site_feedback_query = <<-GRAPHQL
  query($site_id: ID!) {
    site(siteId: $site_id) {
      feedback {
        npsEnabled
        npsAccentColor
        npsSchedule
        npsPhrase
        npsFollowUpEnabled
        npsContactConsentEnabled
        npsLayout
        npsLanguages
        npsLanguagesDefault
        npsExcludedPages
        sentimentEnabled
        sentimentAccentColor
        sentimentExcludedPages
        sentimentLayout
        sentimentDevices
      }
    }
  }
GRAPHQL

RSpec.describe Resolvers::Sites::Feedback, type: :request do
  context 'when there is no feedback' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_feedback_query, variables, user)
    end

    it 'creates it' do
      expect { subject }.to change { site.reload.feedback.nil? }.from(true).to(false)
    end

    it 'returns the created data' do
      response = subject['data']['site']['feedback']
      expect(response).to eq(
        'npsAccentColor' => '#0074E0',
        'npsContactConsentEnabled' => false,
        'npsEnabled' => false,
        'npsExcludedPages' => [],
        'npsFollowUpEnabled' => true,
        'npsLayout' => 'full_width',
        'npsPhrase' => site.name,
        'npsLanguages' => ['en'],
        'npsLanguagesDefault' => 'en',
        'npsSchedule' => 'once',
        'sentimentAccentColor' => '#0074E0',
        'sentimentDevices' => ['desktop', 'tablet'],
        'sentimentEnabled' => false,
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'right_middle'
      )
    end
  end

  context 'when there is feedback' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    before { create(:feedback, site:) }

    subject do
      variables = { site_id: site.id }
      graphql_request(site_feedback_query, variables, user)
    end

    it 'does not create it' do
      expect { subject }.not_to change { Feedback.all.count }
    end

    it 'returns the existing' do
      response = subject['data']['site']['feedback']
      expect(response).to eq(
        'npsAccentColor' => site.feedback.nps_accent_color,
        'npsContactConsentEnabled' => site.feedback.nps_contact_consent_enabled,
        'npsEnabled' => site.feedback.nps_enabled,
        'npsExcludedPages' => site.feedback.nps_excluded_pages,
        'npsFollowUpEnabled' => site.feedback.nps_follow_up_enabled,
        'npsLayout' => site.feedback.nps_layout,
        'npsPhrase' => site.feedback.nps_phrase,
        'npsLanguages' => site.feedback.nps_languages,
        'npsLanguagesDefault' => site.feedback.nps_languages_default,
        'npsSchedule' => site.feedback.nps_schedule,
        'sentimentAccentColor' => site.feedback.sentiment_accent_color,
        'sentimentDevices' => site.feedback.sentiment_devices,
        'sentimentEnabled' => site.feedback.sentiment_enabled,
        'sentimentExcludedPages' => site.feedback.sentiment_excluded_pages,
        'sentimentLayout' => site.feedback.sentiment_layout
      )
    end
  end
end
