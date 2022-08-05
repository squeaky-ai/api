# frozen_string_literal: true

require 'rails_helper'

feedback_update_mutation = <<-GRAPHQL
  mutation($input: FeedbackUpdateInput!) {
    feedbackUpdate(input: $input) {
      npsEnabled
      npsAccentColor
      npsSchedule
      npsPhrase
      npsFollowUpEnabled
      npsContactConsentEnabled
      npsLayout
      npsExcludedPages
      npsHideLogo
      sentimentEnabled
      sentimentAccentColor
      sentimentExcludedPages
      sentimentLayout
      sentimentDevices
      sentimentHideLogo
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
          npsExcludedPages: [],
          sentimentEnabled: true,
          sentimentAccentColor: '#000',
          sentimentExcludedPages: [],
          sentimentLayout: 'bottom_left',
          sentimentDevices: %w[desktop tablet mobile]
        }
      }
      graphql_request(feedback_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['feedbackUpdate']).to eq(
        'npsEnabled' => true,
        'npsAccentColor' => '#000',
        'npsSchedule' => '1_week',
        'npsPhrase' => 'Teapot',
        'npsFollowUpEnabled' => false,
        'npsContactConsentEnabled' => false,
        'npsLayout' => 'bottom_left',
        'npsExcludedPages' => [],
        'npsHideLogo' => false,
        'sentimentEnabled' => true,
        'sentimentAccentColor' => '#000',
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'bottom_left',
        'sentimentDevices' => ['desktop', 'tablet', 'mobile'],
        'sentimentHideLogo' => false
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
        nps_excluded_pages: [],
        sentiment_enabled: true,
        sentiment_accent_color: '#000',
        sentiment_excluded_pages: [],
        sentiment_layout: 'bottom_left',
        sentiment_devices: %w[desktop tablet]
      )
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          npsEnabled: false,
          sentimentAccentColor: '#fff',
          sentimentLayout: 'top_right',
          sentimentDevices: %w[tablet mobile]
        }
      }
      graphql_request(feedback_update_mutation, variables, user)
    end

    it 'returns the data' do
      expect(subject['data']['feedbackUpdate']).to eq(
        'npsEnabled' => false,
        'npsAccentColor' => '#000',
        'npsSchedule' => '1_week',
        'npsPhrase' => 'Teapot',
        'npsFollowUpEnabled' => false,
        'npsContactConsentEnabled' => false,
        'npsLayout' => 'bottom_left',
        'npsExcludedPages' => [],
        'npsHideLogo' => false,
        'sentimentEnabled' => true,
        'sentimentAccentColor' => '#fff',
        'sentimentExcludedPages' => [],
        'sentimentLayout' => 'top_right',
        'sentimentDevices' => ['tablet', 'mobile'],
        'sentimentHideLogo' => false
      )
    end

    it 'does not create a new record' do
      expect { subject }.not_to change { site.reload.feedback.nil? }
    end
  end

  context 'when they are trying to update the logo status' do
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
        nps_excluded_pages: [],
        nps_hide_logo: false,
        sentiment_enabled: true,
        sentiment_accent_color: '#000',
        sentiment_excluded_pages: [],
        sentiment_layout: 'bottom_left',
        sentiment_devices: %w[desktop tablet],
        sentiment_hide_logo: false
      )
    end

    subject do
      variables = {
        input: {
          siteId: site.id,
          npsHideLogo: true,
          sentimentHideLogo: true
        }
      }
      graphql_request(feedback_update_mutation, variables, user)
    end

    context 'and they are on the free tier' do
      before do
        site.plan.update(tier: 0)
      end

      it 'does not update the logo settings' do
        subject
        feedback = site.reload.feedback
        expect(site.reload.feedback.nps_hide_logo).to eq(false)
        expect(site.reload.feedback.sentiment_hide_logo).to eq(false)
      end
    end

    context 'and they are paying' do
      before do
        site.plan.update(tier: 1)
      end

      it 'updates the logo settings' do
        subject
        feedback = site.reload.feedback
        expect(site.reload.feedback.nps_hide_logo).to eq(true)
        expect(site.reload.feedback.sentiment_hide_logo).to eq(true)
      end
    end
  end
end
