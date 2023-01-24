# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe 'POST /events' do
    subject { post :create, body:, as: :json }

    context 'when the name is missing' do
      let(:body) { {}.to_json }

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'name is required')
      end
    end

    context 'when the data is missing' do
      let(:body) do
        {
          'name' => 'MyEvent'
        }.to_json
      end

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'data is required')
      end
    end

    context 'when the user_id is missing' do
      let(:body) do
        {
          'name' => 'MyEvent',
          'data' => '{}'
        }.to_json
      end

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'user_id is required')
      end
    end

    context 'when the api_key does not match the site' do
      let(:body) do
        {
          'name' => 'MyEvent',
          'data' => '{}',
          'user_id' => '234234234'
        }.to_json
      end

      it 'returns unauthorized' do
        subject
        expect(response).to have_http_status(401)
        expect(json_body).to eq('error' => 'Unauthorized')
      end
    end

    context 'when there is no matching visitor' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }

      let(:body) do
        {
          'name' => 'MyEvent',
          'data' => '{}',
          'user_id' => '234234234'
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
      end

      it 'returns unauthorized' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'Data linking is not configured for this user_id')
      end
    end

    context 'when there is a matching visitor' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }
      let(:visitor) { create(:visitor, site_id: site.id, external_attributes: { id: '3821371123' }) }

      let(:body) do
        {
          'name' => 'MyEvent',
          'data' => '{"foo":"bar"}',
          'user_id' => visitor.external_attributes['id']
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
      end

      it 'returns created' do
        subject
        expect(response).to have_http_status(201)
        expect(json_body).to eq('status' => 'OK')
      end

      it 'creates the event' do
        subject
        results = Sql::ClickHouse.select_all("
          SELECT site_id, recording_id, name, data, url, viewport_x, viewport_y, device_x, device_y, source, visitor_id
          FROM custom_events
          WHERE site_id = #{site.id} AND visitor_id = #{visitor.id}
        ")
        expect(results).to match_array([
          {
            'site_id' => site.id,
            'recording_id' => 0,
            'name' => 'MyEvent',
            'data' => '{"foo":"bar"}',
            'url' => '',
            'viewport_x' => 0,
            'viewport_y' => 0,
            'device_x' => 0,
            'device_y' => 0,
            'source' => 'api',
            'visitor_id' => visitor.id
          }
        ])
      end
    end

    context 'when ingest is disabled' do
      let(:site) { create(:site, api_key: SecureRandom.uuid, ingest_enabled: false) }
      let(:visitor) { create(:visitor, site_id: site.id, external_attributes: { id: '3821371123' }) }

      let(:body) do
        {
          'name' => 'MyEvent',
          'data' => '{}',
          'user_id' => visitor.external_attributes['id']
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
      end

      it 'returns forbidden' do
        subject
        expect(response).to have_http_status(403)
        expect(json_body).to eq('error' => 'Forbidden')
      end
    end
  end
end
