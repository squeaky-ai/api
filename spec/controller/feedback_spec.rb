# frozen_string_literal: true

require 'rails_helper'
require 'securerandom'

RSpec.describe FeedbackController, type: :controller do
  describe 'GET /index' do
    context 'when the site does not exist' do
      it 'returns the default arguments' do
        get :index, params: { site_id: SecureRandom.uuid }

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ nps_enabled: false, sentiment_enabled: false}.to_json)
      end
    end

    context 'when the site exists but has no feedback settings' do
      let(:site) { create(:site) }

      it 'returns the default arguments' do
        get :index, params: { site_id: site.uuid }

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq({ nps_enabled: false, sentiment_enabled: false}.to_json)
      end
    end

    context 'when the site exists and has feedback settings' do
      let(:site) { create(:site) }

      let(:settings) do
        {
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
        }
      end

      before { Feedback.create(site: site, **settings) }

      it 'returns the default arguments' do
        get :index, params: { site_id: site.uuid }

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.body).to eq(settings.to_json)
      end
    end
  end
end
