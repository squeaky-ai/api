# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactMailer, type: :mailer do
  describe '#contact' do
    let(:first_name) { 'Bob' }
    let(:last_name) { 'Dylan' }
    let(:email) { 'bobbyd@gmail.com' }
    let(:subject) { 'Hello' }
    let(:message) { '🙀' }

    let(:mail) do
      described_class.contact(
        first_name:,
        last_name:,
        email:,
        subject:,
        message:
      )
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Contact form'
      expect(mail.to).to eq ['hello@squeaky.ai']
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end

  describe '#book_demo' do
    let(:first_name) { 'Bob' }
    let(:last_name) { 'Dylan' }
    let(:email) { 'bobbyd@gmail.com' }
    let(:telephone) { '1238123912' }
    let(:company_name) { 'Squeeeeeeeeek' }
    let(:traffic) { 'Loads' }
    let(:message) { '🌯' }

    let(:mail) do
      described_class.book_demo(
        first_name:,
        last_name:,
        email:,
        subject:,
        message:
      )
    end

    it 'renders the headers' do
      expect(mail.subject).to eq 'Book demo form'
      expect(mail.to).to eq ['hello@squeaky.ai']
      expect(mail.from).to eq ['hello@squeaky.ai']
    end
  end
end
