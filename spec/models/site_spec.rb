# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Site, type: :model do
  describe '.format_uri' do
    context 'when no uri is provided' do
      it 'raises an exception' do
        expect { Site.format_uri(nil) }.to raise_error(ArgumentError)
      end
    end

    context 'when the uri is not invalid' do
      it 'returns nil' do
        uri = 'dfgdfgdf'
        expect(Site.format_uri(uri)).to be nil
      end
    end

    context 'when the uri is valid' do
      it 'returns the uri' do
        uri = 'https://squeaky.ai'
        expect(Site.format_uri(uri)).to eq uri
      end

      it 'strips the path if it exists' do
        uri = 'https://squeaky.ai/pricing'
        expect(Site.format_uri(uri)).to eq 'https://squeaky.ai'
      end

      it 'strips the query string if it exists' do
        uri = 'https://squeaky.ai?teapot=kettle'
        expect(Site.format_uri(uri)).to eq 'https://squeaky.ai'
      end
    end
  end

  describe '#owner_name' do
    let(:user) { create_user }
    let(:subject) { create_site_and_team(user) }

    it 'returns the owners full name' do
      expect(subject.owner_name).to eq "#{user.first_name} #{user.last_name}"
    end
  end

  describe '#admins' do
    let(:subject) { create_site }

    before do
      create_team(user: create_user, site: subject, role: 0)
      create_team(user: create_user, site: subject, role: 1)
      create_team(user: create_user, site: subject, role: 2)
    end

    it 'returns only the team members that are admins' do
      admins = subject.admins

      expect(admins.size).to eq 2
      admins.each { |a| expect(a.admin?).to be true }
    end
  end
end
