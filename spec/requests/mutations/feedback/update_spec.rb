# frozen_string_literal: true

require 'rails_helper'

feedback_update_mutation = <<-GRAPHQL
  mutation($input: FeedbackUpdateInput!) {
    feedbackUpdate(input: $input) {
      feedback {
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
      }
    }
  }
GRAPHQL

RSpec.describe Mutations::Feedback::Update, type: :request do
  context 'when there is nothing in the database' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject do
      variables = {
        input: {
          siteId: site.id,
          npsEnabled: true,
          npsAccentColor: '#000',
          npsSchedule: '1_week',
          npsPhrase: 'Teapot',
          npsFollowUpEnabled: false,
          npsContactConsentEnabled: false,
          npsLayout: 'bottom_left',
          sentimentEnabled: true,
          sentimentAccentColor: '#000',
          sentimentExcludedPages: [],
          sentimentLayout: 'bottom_left'
        }
      }
      graphql_request(feedback_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['feedbackUpdate']['feedback']).to eq(
        'npsEnabled' => true,
        'npsAccentColor' => '#000',
        'npsSchedule' => '1_week',
        'npsPhrase' => 'Teapot',
        'npsFollowUpEnabled' => false,
        'npsContactConsentEnabled' => false,
        'npsLayout' => 'bottom_left',
        'sentimentEnabled' => true,
        'sentimentAccentColor' => '#000',
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'bottom_left'
      )
    end

    it 'upserts the record' do
      expect { subject }.to change { site.reload.feedback.nil? }.from(true).to(false)
    end
  end

  context 'when there is something in the database' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

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
        sentiment_layout: 'bottom_left'
      )
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          npsEnabled: false,
          sentimentAccentColor: '#fff',
          sentimentLayout: 'top_right'
        }
      }
      graphql_request(feedback_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['feedbackUpdate']['feedback']).to eq(
        'npsEnabled' => false,
        'npsAccentColor' => '#000',
        'npsSchedule' => '1_week',
        'npsPhrase' => 'Teapot',
        'npsFollowUpEnabled' => false,
        'npsContactConsentEnabled' => false,
        'npsLayout' => 'bottom_left',
        'sentimentEnabled' => true,
        'sentimentAccentColor' => '#fff',
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'top_right'
      )
    end

    it 'does not create a new record' do
      expect { subject }.not_to change { site.reload.feedback.nil? }
    end
  end
end
