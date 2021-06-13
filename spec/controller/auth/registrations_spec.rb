# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::RegistrationsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET /email_exists' do
    context 'when the email is not registered' do
      it 'returns false' do
        get :email_exists, params: { email: Faker::Internet.email }

        expect(response).to have_http_status(200)
        expect(response.body).to eq({ exists: false }.to_json)
      end
    end

    context 'when the email is registered' do
      let(:user) { create_user }

      it 'returns true' do
        get :email_exists, params: { email: user.email }

        expect(response).to have_http_status(200)
        expect(response.body).to eq({ exists: true }.to_json)
      end
    end
  end
end
