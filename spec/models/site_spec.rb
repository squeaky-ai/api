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
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }

    subject { site.owner_name }

    it 'returns the owners full name' do
      expect(subject).to eq "#{user.first_name} #{user.last_name}"
    end
  end

  describe '#admins' do
    let(:site) { create(:site) }

    subject { site.admins }

    before do
      create(:team, site: site, role: Team::MEMBER)
      create(:team, site: site, role: Team::ADMIN)
      create(:team, site: site, role: Team::OWNER)
    end

    it 'returns only the team members that are admins' do
      expect(subject.size).to eq 1
      subject.each { |a| expect(a.admin?).to be true }
    end
  end

  describe '#owner' do
    let(:user) { create(:user) }
    let(:site) { create(:site) }
    let(:team) { create(:team, user: user, site: site, role: Team::OWNER) }

    subject { site.owner }

    before { team }

    it 'returns the owner' do
      expect(subject).to eq team
    end
  end

  describe '#member' do
    context 'when a member exists' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      let(:team) { create(:team, site: site, role: Team::ADMIN) }

      subject { site.member(team.id) }

      it 'returns the team member' do
        expect(subject).to eq team
      end
    end

    context 'when a member does not exist' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject { site.member(423) }

      it 'returns nil' do
        expect(subject).to be nil
      end
    end
  end

  describe '#recordings_count' do
    context 'when there are no recordings' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      subject { site.recordings_count }

      it 'returns 0' do
        expect(subject).to eq 0
      end
    end

    context 'when there are some recordings' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }

      before do
        create(:recording, site: site)
        create(:recording, site: site)
        create(:recording, status: Recording::DELETED, site: site)
      end

      subject { site.recordings_count }

      it 'returns the number of un-deleted recordings' do
        expect(subject).to eq 2
      end
    end
  end

  describe '#page_urls' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team, owner: user) }
    let(:recording) { create(:recording, site: site) }

    before do
      create(:page, url: '/' , recording: recording)
      create(:page, url: '/foo', recording: recording)
      create(:page, url: '/foo', recording: recording)
    end

    subject { site.page_urls }

    it 'returns a list of page urls' do
      expect(subject).to eq(['/', '/foo'])
    end
  end

  describe '#active_user_count' do
    context 'when there is nothing in Redis' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
  
      subject { site.active_user_count }

      it 'returns 0' do
        expect(subject).to eq(0)
      end
    end

    context 'when there is something in Redis' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team, owner: user) }
      
      before do
        Cache.redis.zincrby('active_user_count', 5, site.uuid)
      end
  
      subject { site.active_user_count }

      it 'returns the count' do
        expect(subject).to eq(5)
      end
    end
  end
end
