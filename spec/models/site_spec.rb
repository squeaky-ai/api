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

    subject { site.owner_name }

    it 'returns the owners full name' do
      expect(subject).to eq "#{user.first_name} #{user.last_name}"
    end
  end

  describe '#admins' do
    let(:site) { create_site }

    subject { site.admins }

    before do
      create_team(user: create_user, site: site, role: Team::MEMBER)
      create_team(user: create_user, site: site, role: Team::ADMIN)
      create_team(user: create_user, site: site, role: Team::OWNER)
    end

    it 'returns only the team members that are admins' do
      expect(subject.size).to eq 1
      subject.each { |a| expect(a.admin?).to be true }
    end
  end

  describe '#owner' do
    let(:user) { create_user }
    let(:site) { create_site }
    let(:team) { create_team(user: user, site: site, role: Team::OWNER) }

    subject { site.owner }

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

      subject { site.member(team.id) }

      it 'returns the team member' do
        expect(subject).to eq team
      end
    end

    context 'when a member does not exist' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject { site.member(423) }

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

  describe '#recordings_count' do
    context 'when there are no recordings' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject { site.recordings_count }

      it 'returns 0' do
        expect(subject).to eq 0
      end
    end

    context 'when there are some recordings' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        create_recording(site: site, visitor: create_visitor)
        create_recording(site: site, visitor: create_visitor)
        create_recording({ deleted: true }, site: site, visitor: create_visitor)
      end

      subject { site.recordings_count }

      it 'returns the number of un-deleted recordings' do
        expect(subject).to eq 2
      end
    end
  end

  describe '#team_size_exceeded?' do
    context 'when the count is less' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_team_members).and_return(2)
      end

      subject { site.team_size_exceeded? }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the count is equal' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_team_members).and_return(1)
      end

      subject { site.team_size_exceeded? }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the count is greater' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_team_members).and_return(1)
        create_team(user: create_user, site: site, role: Team::MEMBER)
      end

      subject { site.team_size_exceeded? }

      it 'returns true' do
        expect(subject).to be true
      end
    end
  end

  describe '#recording_count_exceeded?' do
    context 'when there are no recordings' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      subject { site.recording_count_exceeded? }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when there are less recordings than the limit' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(2)
        create_recording(site: site, visitor: create_visitor)
      end

      subject { site.recording_count_exceeded? }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when there are equal recordings than the limit' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(1)
        create_recording(site: site, visitor: create_visitor)
      end

      subject { site.recording_count_exceeded? }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when there are more recordings than the limit' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(1)
        create_recording(site: site, visitor: create_visitor)
        create_recording(site: site, visitor: create_visitor)
      end

      subject { site.recording_count_exceeded? }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when there are more recordings but they are from a different month' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        last_month = Time.now - 1.month

        allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(1)
        create_recording({ created_at: last_month }, site: site, visitor: create_visitor)
        create_recording({ created_at: last_month }, site: site, visitor: create_visitor)
      end

      subject { site.recording_count_exceeded? }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when there are more recordings but they are soft deleted' do
      let(:user) { create_user }
      let(:site) { create_site_and_team(user: user) }

      before do
        allow_any_instance_of(Plan).to receive(:max_monthly_recordings).and_return(1)
        create_recording({ deleted: true }, site: site, visitor: create_visitor)
        create_recording({ deleted: true }, site: site, visitor: create_visitor)
      end

      subject { site.recording_count_exceeded? }

      it 'returns false' do
        expect(subject).to be false
      end
    end
  end
end
