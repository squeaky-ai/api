# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TeamMailer, type: :mailer do
  describe 'invite' do
    let(:token) { '__fake_jwt__' }
    let(:email) { Faker::Internet.email }
    let(:site) { create_site }
    let(:user) { create_user }

    let(:mail) { described_class.invite(email, site, user, token) }

    it 'renders the headers' do
      expect(mail.subject).to eq 'You’ve been invited to join Squeaky'
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the token in the body' do
      expect(mail.body.encoded).to include token
    end

    it 'includes the user name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include "#{user.first_name} #{user.last_name}"
    end

    it 'includes the sites name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include site.name
    end
  end

  describe 'member_left' do
    let(:email) { Faker::Internet.email }
    let(:user) { create_user }
    let(:site) { create_site }
    let(:mail) { described_class.member_left(email, site, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq "A user has left your #{site.name} team."
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the user name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include "#{user.first_name} #{user.last_name}"
    end

    it 'includes the sites name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include site.name
    end
  end

  describe 'member_removed' do
    let(:email) { Faker::Internet.email }
    let(:site) { create_site }
    let(:mail) { described_class.member_removed(email, site) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You have been removed from the #{site.name} team on Squeaky."
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the sites name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include site.name
    end
  end

  describe 'became_admin' do
    let(:email) { Faker::Internet.email }
    let(:site) { create_site }
    let(:user) { create_user }
    let(:mail) { described_class.became_admin(email, site, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You’ve been made the Admin of #{site.name}"
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the user name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include "#{user.first_name} #{user.last_name}"
    end

    it 'includes the sites name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include site.name
    end
  end

  describe 'became_owner' do
    let(:email) { Faker::Internet.email }
    let(:site) { create_site }
    let(:user) { create_user }
    let(:mail) { described_class.became_owner(email, site, user) }

    it 'renders the headers' do
      expect(mail.subject).to eq "You’ve been made Owner of #{site.name}"
      expect(mail.to).to eq [email]
      expect(mail.from).to eq ['hello@squeaky.ai']
    end

    it 'includes the user name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include "#{user.first_name} #{user.last_name}"
    end

    it 'includes the sites name in the body' do
      body = mail.body.encoded.sub('&#39;', '\'')
      expect(body).to include site.name
    end
  end
end
