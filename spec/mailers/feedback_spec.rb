# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  describe 'feedback' do
    let(:user) { create_user }
    let(:type) { 'feedback' }
    let(:subject) { 'Hello!' }
    let(:message) { 'Hello again!' }
    let(:mail) { described_class.feedback(user, type, subject, message) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'User feedback'
      expect(mail.to).to eq ['hello@squeaky.ai']
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end
end
