# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Uninstall do
  describe '#uninstall!' do
    let(:site) { create(:site) }

    let!(:recording_1) { create(:recording, site:) }
    let!(:recording_2) { create(:recording, site:) }

    let!(:team_1) { create(:team, site:, role: Team::OWNER) }
    let!(:team_2) { create(:team, site:, role: Team::MEMBER) }
    let!(:team_3) { create(:team, site:, role: Team::MEMBER) }

    subject { described_class.new(site_name: site.uuid).uninstall! }

    before do
      site.reload
    end

    it 'deletes the site' do
      subject
      expect { site.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the team members' do
      expect { subject }.to change { Team.all.size }.from(3).to(0)
    end

    it 'deletes the users' do
      expect { subject }.to change { User.all.size }.from(3).to(0)
    end

    it 'kicks off some jobs to clean up the recordings' do
      ActiveJob::Base.queue_adapter = :test

      subject
      expect(RecordingDeleteJob).to have_been_enqueued.once.with(match_array([recording_1.id, recording_2.id]))
    end

    context 'if one of the members is a member of another site' do
      before do
        additional_site = create(:site)
        create(:team, site: additional_site, user: team_3.user, role: Team::MEMBER)
      end

      it 'deletes the team members' do
        expect { subject }.to change { Team.all.size }.by(-3)
      end

      it 'does not delete that users account' do
        expect { subject }.to change { User.all.size }.from(3).to(1)
      end
    end
  end
end