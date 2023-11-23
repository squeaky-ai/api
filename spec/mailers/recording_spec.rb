# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecordingMailer, type: :mailer do
  describe '#first_recording' do
    describe 'when the site no longer exists' do
      let(:mail) { described_class.first_recording(23423423) }

      it 'does not send anything' do
        expect(mail.to).to eq nil
      end
    end

    describe 'when the site exists' do
      let(:site) { create(:site_with_team) }
      let(:mail) { described_class.first_recording(site.id) }

      let(:team_1) { create(:team, site:, role: Team::ADMIN) }
      let(:team_2) { create(:team, site:, role: Team::ADMIN) }
      let(:team_3) { create(:team, site:, role: Team::MEMBER) }

      before do
        create(:communication, user: team_1.user, onboarding_email: true)
        create(:communication, user: team_2.user, onboarding_email: false)
        create(:communication, user: team_3.user, onboarding_email: true)
      end

      it 'sends the email to owners and admins that have preferences enabled' do
        expect(mail.subject).to eq 'Your first Squeaky recording is in! 👀'
        expect(mail.from).to eq ['hello@squeaky.ai']
        expect(mail.to).to eq [site.owner.user.email, team_1.user.email]
      end
    end
  end
end
