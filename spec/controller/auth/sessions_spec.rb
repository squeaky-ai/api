# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :controller do
  before { @request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET /current' do
    context 'when the user is not logged in' do
      it 'returns unauthorized' do
        get :current
        expect(response).to have_http_status(401)
        expect(response.body).to eq ' '
      end
    end

    context 'when the user is logged in' do
      let(:user) { create_user }

      it 'returns the serialized user' do
        sign_in user
        get :current
        expect(response).to have_http_status(200)
        expect(response.body).to eq(user.to_h.to_json)
      end
    end
  end
end
