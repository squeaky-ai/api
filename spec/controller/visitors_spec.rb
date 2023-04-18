# frozen_string_literal: true

require 'rails_helper'

RSpec.describe VisitorsController, type: :controller do
  describe 'POST /visitors' do
    subject { post :create, body:, as: :json }

    context 'when no api_key is given' do
      let(:body) do
        {
          'data' => '{}',
          'user_id' => '234234234'
        }.to_json
      end

      it 'returns forbidden' do
        subject
        expect(response).to have_http_status(403)
        expect(json_body).to eq('error' => 'Forbidden')
      end
    end

    context 'when the api_key does not match the site' do
      let(:body) do
        {
          'data' => '{}',
          'user_id' => '234234234'
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = SecureRandom.uuid
      end

      it 'returns unauthorized' do
        subject
        expect(response).to have_http_status(403)
        expect(json_body).to eq('error' => 'Forbidden')
      end
    end

    context 'when the user_id is missing' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }

      let(:body) { {}.to_json }

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
        site.plan.update(features_enabled: ['event_tracking'])
      end

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'user_id is required')
      end
    end

    context 'when the data is missing' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }

      let(:body) do
        {
          'user_id' => 1
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
        site.plan.update(features_enabled: ['event_tracking'])
      end

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(400)
        expect(json_body).to eq('error' => 'data is required')
      end
    end

    context 'when the visitor exists already' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }
      let!(:visitor) { create(:visitor, site_id: site.id, external_attributes: { id: 5 }) }

      let(:body) do
        {
          'user_id' => visitor.external_attributes['id'],
          'data' => '{}'
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
        site.plan.update(features_enabled: ['event_tracking'])
      end

      it 'returns a bad request' do
        subject
        expect(response).to have_http_status(409)
        expect(json_body).to eq('error' => 'Visitor already exists')
      end
    end

    context 'when ingest is disabled' do
      let(:site) { create(:site, api_key: SecureRandom.uuid, ingest_enabled: false) }
      let(:visitor) { create(:visitor, site_id: site.id) }

      let(:body) do
        {
          'data' => '{}',
          'user_id' => 345345345345
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
        site.plan.update(features_enabled: ['event_tracking'])
      end

      it 'returns unauthorized' do
        subject
        expect(response).to have_http_status(401)
        expect(json_body).to eq('error' => 'Unauthorized')
      end
    end

    context 'when all is good' do
      let(:site) { create(:site, api_key: SecureRandom.uuid) }

      let(:body) do
        {
          'data' => '{"email": "foo@bar.com", "other_prop": true}',
          'user_id' => 1234234234
        }.to_json
      end

      before do
        request.headers['X-SQUEAKY-API-KEY'] = site.api_key
        site.plan.update(features_enabled: ['event_tracking'])
      end

      it 'returns success' do
        subject
        expect(response).to have_http_status(201)
        expect(json_body).to eq('status' => 'OK')
      end

      it 'creates a visitor' do
        expect { subject }.to change { site.reload.visitors.size }.by(1)
      end

      it 'has the correct params' do
        subject
        visitor = Visitor.last
        expect(visitor.source).to eq(Visitor::API)
        expect(visitor.external_attributes).to eq(
          'id' => '1234234234',
          'email' => 'foo@bar.com',
          'other_prop' => 'true'
        )
      end
    end
  end
end
