# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'updated' do
    let(:user) { create_user }
    let(:mail) { described_class.updated(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Your account details have been updated.'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end
end
