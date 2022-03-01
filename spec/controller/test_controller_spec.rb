# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TestController, type: :controller do
  describe 'POST /test/user' do
    let(:email) { 'sdfsfsd@bar.com' }
    let(:password) { '1234dfgdfgd!!' }

    subject do
      post :create_user, params: { email:, password: }
    end

    it 'returns the created user' do
      subject

      expect(response).to have_http_status(200)
      expect(JSON.parse(response.body)).to match(a_hash_including(
        'first_name' => nil,
        'last_name' => nil,
        'email' => email,
      ))
    end

    it 'deletes the user' do
      expect { subject }.to change { User.all.size }.by(1)
    end
  end

  describe 'DELETE /test/user' do
    let(:user) { create(:user) }

    before { user }

    subject do
      delete :destroy_user, params: { email: user.email }
    end

    it 'returns no body' do
      subject

      expect(response).to have_http_status(200)
      expect(response.body).to eq('')
    end

    it 'destroys the user' do
      expect { subject }.to change { User.all.size }.by(-1)
    end
  end
end
