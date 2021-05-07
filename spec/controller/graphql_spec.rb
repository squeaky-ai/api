# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe '#current_user' do
    context 'when the authorization header is missing' do
      it 'returns nil' do
        expect(controller.send(:current_user)).to be nil
      end
    end

    context 'when the authorization header is present' do
      context 'and it is full of garbage' do
        it 'returns nil' do
          request.headers['Authorization'] = 'dflgkjdgldf'
          expect(controller.send(:current_user)).to be nil
        end
      end

      context 'and it contains an invalid bearer token' do
        it 'returns nil' do
          request.headers['Authorization'] = 'Bearer kl23j4kl2343'
          expect(controller.send(:current_user)).to be nil
        end
      end

      context 'and it contains a valid bearer token' do
        let(:user) { User.create(email: Faker::Internet.email) }

        it 'returns the user in the token' do
          request.headers['Authorization'] = "Bearer #{JsonWebToken.encode(id: user.id)}"
          expect(controller.send(:current_user)).to eq user
        end
      end
    end
  end
end
