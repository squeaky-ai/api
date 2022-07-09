# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductUpdatesMailer, type: :mailer do
  describe 'q2_2022' do
    let(:user) { create(:user) }
    let(:mail) { described_class.q2_2022(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'Product Update: Q2 2022.'
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end
end
