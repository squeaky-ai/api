# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::SessionsController, type: :request do
  describe 'POST /auth/sign_in' do
    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    subject { post '/auth/sign_in', params: params.to_json, headers: }

    context 'when the user does not exist' do
      let(:params) do
        {
          user: {
            email: 'sdklfsdj@gmail.com',
            password: 'sdfsdfsfsd'
          }
        }
      end

      it 'returns an unsuccessful response' do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to include('Invalid Email or password')
      end
    end

    context 'when the user exists but the password is wrong' do
      let(:user) { create(:user) }

      let(:params) do
        {
          user: {
            email: user.email,
            password: 'sdfsdfsfsd'
          }
        }
      end

      it 'returns an unsuccessful response' do
        subject
        expect(response.status).to eq(401)
        expect(response.body).to include('Invalid Email or password')
      end
    end

    context 'when the user exists and the password is correct' do
      let(:user) { create(:user) }

      let(:params) do
        {
          user: {
            email: user.email,
            password: user.password
          }
        }
      end

      it 'returns an successful response' do
        subject
        expect(response.status).to eq(200)
        expect(response.parsed_body['id']).to eq(user.id)
        expect(response.parsed_body['first_name']).to eq(user.first_name)
        expect(response.parsed_body['last_name']).to eq(user.last_name)
        expect(response.parsed_body['email']).to eq(user.email)
      end
    end
  end

  describe 'DELETE /auth/sign_out' do
    let(:headers) do
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json'
      }
    end

    subject { delete '/auth/sign_out', headers: }

    it 'returns a 204 status' do
      subject
      expect(response.status).to eq(204)
    end
  end
end
