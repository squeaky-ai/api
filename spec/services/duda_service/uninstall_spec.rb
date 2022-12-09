# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DudaService::Uninstall do
  describe '#uninstall!' do
    ActiveJob::Base.queue_adapter = :test

    let(:site) { create(:site) }

    subject { described_class.new(site_name: site.uuid).uninstall! }

    before do
      create(:team, site:, role: Team::MEMBER)
      create(:team, site:, role: Team::MEMBER)
      create(:team, site:, role: Team::MEMBER)

      create(:recording, site:)
      create(:recording, site:)

      site.reload
    end

    it 'deletes the site' do
      subject
      expect { site.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'deletes the team members' do
      expect { subject }.to change { Team.all.size }.from(3).to(0)
    end

    it 'kicks off some jobs to clean up the recordings' do
      subject
      expect(RecordingDeleteJob).to have_been_enqueued.twice
    end
  end
end