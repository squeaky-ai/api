# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GraphqlController, type: :controller do
  describe '#current_user!' do
    context 'when the user is not logged in' do
      it 'throws an error' do
        expect { controller.send(:current_user!) }.to raise_error(Errors::Unauthorized)
      end
    end

    context 'when the user is logged in' do
      let(:user) { create_user }

      before { @request.env['devise.mapping'] = Devise.mappings[:user] }

      it 'returns the user' do
        sign_in user
        expect(controller.send(:current_user!)).to eq user
      end
    end
  end
end
