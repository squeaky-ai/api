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
    let(:instance) { described_class.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0) }

    let(:user) { create_user }

    before { Team.create(role: 2, user: user, site: instance) }

    it 'returns the owners full name' do
      expect(instance.owner_name).to eq "#{user.first_name} #{user.last_name}"
    end
  end

  describe '#admins' do
    let(:instance) { described_class.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0) }

    before do
      Team.create(role: 0, user: User.new, site: instance)
      Team.create(role: 1, user: User.new, site: instance)
      Team.create(role: 2, user: User.new, site: instance)
      instance.reload
    end

    it 'returns only the team members that are admins' do
      admins = instance.admins

      expect(admins.size).to eq 2
      admins.each { |a| expect(a.admin?).to be true }
    end
  end
end
