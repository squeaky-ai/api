# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AuthMailer, type: :mailer do
  describe 'login' do
    let(:email) { Faker::Internet.email }
    let(:token) { '123456' }
    let(:subject) { described_class.login(email, token) }

    it 'renders the headers' do
      expect(subject.subject).to eq 'Log in to Squeaky.ai'
      expect(subject.to).to eq [email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the token in teh body' do
      expect(subject.body.encoded).to include token
    end
  end

  describe 'signup' do
    let(:email) { Faker::Internet.email }
    let(:token) { '123456' }
    let(:subject) { described_class.signup(email, token) }

    it 'renders the headers' do
      expect(subject.subject).to eq 'Your sign-up code for Squeaky.ai'
      expect(subject.to).to eq [email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the token in the body' do
      expect(subject.body.encoded).to include token
    end
  end
end
