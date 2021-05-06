# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamMailer, type: :mailer do
  describe 'invite' do
    let(:token) { '__fake_jwt__' }
    let(:email) { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:site_name) { Faker::Company.name }

    let(:site) { Site.create(name: site_name, url: Faker::Internet.url, plan: 0) }
    let(:inviter) { User.create(first_name: first_name, last_name: last_name) }

    let(:mail) { described_class.invite(email, site, inviter, token) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You’ve been invited to join Squeaky'
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the token in the body' do
      expect(mail.body.encoded).to include token
    end

    it 'includes the inviters name in the body' do
      expect(mail.body.encoded).to include "#{first_name} #{last_name}"
    end

    it 'includes the sites name in the body' do
      expect(mail.body.encoded).to include site_name
    end
  end

  describe 'member_left' do
    let(:email) { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:site_name) { Faker::Company.name }

    let(:site) { Site.create(name: site_name, url: Faker::Internet.url, plan: 0) }
    let(:leaver) { User.create(first_name: first_name, last_name: last_name) }

    let(:mail) { described_class.member_left(email, site, leaver) }

    it 'renders the headers' do
      expect(mail.subject).to eq "A user has left your #{site.name} team."
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the leavers name in the body' do
      expect(mail.body.encoded).to include "#{first_name} #{last_name}"
    end

    it 'includes the sites name in the body' do
      expect(mail.body.encoded).to include site_name
    end
  end

  describe 'member_removed' do
    let(:email) { Faker::Internet.email }
    let(:first_name) { Faker::Name.first_name }
    let(:last_name) { Faker::Name.last_name }
    let(:site_name) { Faker::Company.name }

    let(:site) { Site.create(name: site_name, url: Faker::Internet.url, plan: 0) }
    let(:user) { User.create(first_name: first_name, last_name: last_name) }

    let(:mail) { described_class.member_removed(email, site, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You have been removed from the #{site.name} team on Squeaky."
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the sites name in the body' do
      expect(mail.body.encoded).to include site_name
    end
  end
end
