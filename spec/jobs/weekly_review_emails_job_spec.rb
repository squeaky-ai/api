# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewEmailsJob, type: :job do
  include ActiveJob::TestHelper

  let(:site_1) { create(:site) }
  let(:site_2) { create(:site) }
  let(:site_3) { create(:site) }

  let(:team_1) { create(:team, site: site_1, role: Team::MEMBER) }
  let(:team_2) { create(:team, site: site_2, role: Team::MEMBER) }
  let(:team_3) { create(:team, site: site_3, role: Team::MEMBER) }
  let(:team_4) { create(:team, site: site_3, role: Team::ADMIN) }

  let(:recordings) do
    [
      create(:recording, site: site_1, disconnected_at: 1641151425390),
      create(:recording, site: site_2, disconnected_at: 1644718425390),
      create(:recording, site: site_3, disconnected_at: 1644331425390)
    ]
  end

  before do
    today = Date.new(2022, 2, 14)

    allow(Time.zone).to receive(:today).and_return(today)
    allow(SiteMailer).to receive(:weekly_review).and_call_original

    ClickHouse::Recording.insert do |buffer|
      recordings.each do |recording|
        buffer << {
          uuid: SecureRandom.uuid,
          site_id: recording.site.id,
          recording_id: recording.id,
          disconnected_at: recording.disconnected_at
        }
      end
    end
  end

  subject { described_class.perform_now }

  it 'triggers the emails for all sites that qualify' do
    # Site 1 only had recordings in the previous week
    expect(SiteMailer).not_to receive(:weekly_review).with(site_1, anything, team_1.user)
    # The other 2 sites both had recordings in the time frame
    expect(SiteMailer).to receive(:weekly_review).with(site_2, anything, team_2.user)
    expect(SiteMailer).to receive(:weekly_review).with(site_3, anything, team_3.user)
    expect(SiteMailer).to receive(:weekly_review).with(site_3, anything, team_4.user)
    subject
  end

  context 'when a date range is provided to the job' do
    let(:from_date) { Date.new(2021, 12, 27) }
    let(:to_date) { Date.new(2022, 1, 2) }

    subject { described_class.perform_now({ from_date:, to_date: }) }

    it 'uses that instead of the previous week' do
      # Site 1 had a recording on the 2nd January
      expect(SiteMailer).to receive(:weekly_review).with(site_1, anything, team_1.user)
      # The other 2 sites had recordings much later
      expect(SiteMailer).not_to receive(:weekly_review).with(site_2, anything, team_2.user)
      expect(SiteMailer).not_to receive(:weekly_review).with(site_3, anything, team_3.user)
      expect(SiteMailer).not_to receive(:weekly_review).with(site_3, anything, team_4.user)
      subject
    end
  end
end
