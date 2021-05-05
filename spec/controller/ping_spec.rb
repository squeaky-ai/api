# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PingController, type: :controller do
  describe 'GET /index' do
    context 'when redis and the database are available' do
      it 'returns PONG' do
        get :index
        expect(response).to have_http_status(200)
        expect(response.body).to eq 'PONG'
      end
    end

    context 'when redis is unavailable' do
      before do
        allow(Redis.current).to receive('ping').and_raise(StandardError)
      end

      it 'returns NOT PONG' do
        get :index
        expect(response).to have_http_status(500)
        expect(response.body).to eq 'NOT PONG!'
      end
    end

    context 'when the database is unavailable' do
      before do
        allow(ActiveRecord::Base.connection).to receive('verify!').and_raise(StandardError)
      end

      it 'returns NOT PONG' do
        get :index
        expect(response).to have_http_status(500)
        expect(response.body).to eq 'NOT PONG!'
      end
    end
  end
end
