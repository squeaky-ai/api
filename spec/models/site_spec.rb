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
    let(:site) { create_site_and_team(user: user) }
    let(:subject) { site.owner_name }

    it 'returns the owners full name' do
      expect(subject).to eq "#{user.first_name} #{user.last_name}"
    end
  end

  describe '#admins' do
    let(:site) { create_site }
    let(:subject) { site.admins }

    before do
      create_team(user: create_user, site: site, role: Team::MEMBER)
      create_team(user: create_user, site: site, role: Team::ADMIN)
      create_team(user: create_user, site: site, role: Team::OWNER)
    end

    it 'returns only the team members that are admins' do
      expect(subject.size).to eq 2
      subject.each { |a| expect(a.admin?).to be true }
    end
  end

  describe '#owner' do
    let(:user) { create_user }
    let(:site) { create_site }
    let(:team) { create_team(user: user, site: site, role: Team::OWNER) }
    let(:subject) { site.owner }

    before { team }

    it 'returns the owner' do
      expect(subject).to eq team
    end
  end

  describe '#member' do
    context 'when a member exists' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }
      let(:team) { create_team(user: create_user, site: site, role: Team::ADMIN) }
      let(:subject) { site.member(team.id) }

      it 'returns the team member' do
        expect(subject).to eq team
      end
    end

    context 'when a member does not exist' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }
      let(:subject) { site.member(423) }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#plan_name' do
    it 'returns the correct plan' do
      expect(create_site(plan: Site::ESSENTIALS).plan_name).to eq 'Essentials'
      expect(create_site(plan: Site::PREMIUM).plan_name).to eq 'Premium'
      expect(create_site(plan: Site::UNLIMITED).plan_name).to eq 'Unlimited'
    end
  end
end
