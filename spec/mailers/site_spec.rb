# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SiteMailer, type: :mailer do
  describe 'destroyed' do
    context 'when the team member is the owner' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team) }
      let!(:team) { create(:team, user:, site:, role: Team::OWNER) }

      let(:mail) { described_class.destroyed(team, site) }

      it 'renders the headers' do
        expect(mail.subject).to eq 'Site deletion follow-up'
        expect(mail.to).to eq [user.email]
        expect(mail.from).to eq ['hello@squeaky.ai']
      end

      it 'includes a link to the survey' do
        expect(mail.body).to include('2-Minute Feedback Survey')
      end
    end

    context 'when the team member is not an owner' do
      let(:user) { create(:user) }
      let(:site) { create(:site_with_team) }
      let!(:team) { create(:team, user:, site:, role: Team::ADMIN) }

      let(:mail) { described_class.destroyed(team, site) }

      it 'renders the headers' do
        expect(mail.subject).to eq "The team account for #{site.name} has been deleted"
        expect(mail.to).to eq [user.email]
        expect(mail.from).to eq ['hello@squeaky.ai']
      end

      it 'renders a message saying the site was deleted' do
        expect(mail.body).to include("The team account for #{site.name} has been deleted")
      end
    end
  end

  describe '#plan_exceeded' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    let(:data) do
      {
        monthly_recording_count: 5000,
        next_plan: 'Light'
      }
    end

    subject { described_class.plan_exceeded(site, data, user) }

    it 'renders the headers' do
      expect(subject.subject).to eq "You've exceeded your monthly visit limit on #{site.name}"
      expect(subject.to).to eq [user.email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end

  describe '#plan_nearing_limit' do
    let(:user) { create(:user) }
    let(:site) { create(:site_with_team) }

    subject { described_class.plan_nearing_limit(site, user) }

    it 'renders the headers' do
      expect(subject.subject).to eq "You'll exceed your monthly visit limit soon for #{site.name}"
      expect(subject.to).to eq [user.email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end

  describe '#new_feedback' do
    let(:site) { create(:site_with_team) }
    let(:user) { site.team.first.user }

    subject { described_class.new_feedback(data, user) }

    let(:data) do
      {
        site:,
        nps: [],
        sentiment: []
      }
    end

    it 'renders the headers' do
      expect(subject.subject).to eq "You've got new feedback from your visitors"
      expect(subject.to).to eq [user.email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end

  describe '#tracking_code_instructions' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }

    let(:first_name) { 'Bob' }
    let(:email) { 'bob@developer.com' }

    subject { described_class.tracking_code_instructions(site, first_name, email) }

    it 'renders the headers' do
      expect(subject.subject).to eq "Your colleague #{owner.full_name} needs your help"
      expect(subject.to).to eq [email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end

  describe '#business_plan_features' do
    let(:owner) { create(:user) }
    let(:site) { create(:site_with_team, owner:) }

    subject { described_class.business_plan_features(site) }

    it 'renders the headers' do
      expect(subject.subject).to eq 'The added benefits of your new Business Plan...'
      expect(subject.to).to eq [owner.email]
      expect(subject.from).to eq ['hello@squeaky.ai']
    end
  end
end
