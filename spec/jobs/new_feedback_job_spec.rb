# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewFeedbackJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now }

  context 'when there has been no feedback' do
    before do
      site_1 = create(:site_with_team)
      site_2 = create(:site_with_team)
      site_3 = create(:site_with_team)
      site_4 = create(:site_with_team) # rubocop:disable Lint/UselessAssignment

      create(:team, site: site_1, role: Team::ADMIN)

      create(:recording, site: site_1)
      create(:recording, site: site_1)
      create(:recording, site: site_2)
      create(:recording, site: site_2)
      create(:recording, site: site_3)
      create(:recording, site: site_3)

      stub = double
      allow(stub).to receive(:deliver_now)
      allow(SiteMailer).to receive(:new_feedback).and_return(stub)
    end

    it 'does not send any mail' do
      subject

      expect(SiteMailer).not_to have_received(:new_feedback)
    end
  end

  context 'when there has been feedback' do
    before do
      # rubocop:disable Lint/UselessAssignment
      now = Time.current

      site_1 = create(:site_with_team)
      site_2 = create(:site_with_team)
      site_3 = create(:site_with_team)
      site_4 = create(:site_with_team)

      create(:team, site: site_1, role: Team::ADMIN)

      recording_1 = create(:recording, site: site_1)
      recording_2 = create(:recording, site: site_1)
      recording_3 = create(:recording, site: site_2)
      recording_4 = create(:recording, site: site_2)
      recording_5 = create(:recording, site: site_3)
      recording_6 = create(:recording, site: site_3)

      nps_1 = create(:nps, recording: recording_1, created_at: now - 30.minutes)
      nps_2 = create(:nps, recording: recording_2, created_at: now - 45.minutes)
      nps_3 = create(:nps, recording: recording_3, created_at: now - 2.hours)
      nps_4 = create(:nps, recording: recording_4, created_at: now - 2.minutes)
      nps_5 = create(:nps, recording: recording_5, created_at: now - 10.days)
      nps_6 = create(:nps, recording: recording_6, created_at: now - 20.minutes)

      sentiment_1 = create(:sentiment, recording: recording_1, created_at: now - 15.minutes)
      sentiment_2 = create(:sentiment, recording: recording_2, created_at: now - 90.minutes)
      sentiment_3 = create(:sentiment, recording: recording_3, created_at: now - 5.hours)
      sentiment_4 = create(:sentiment, recording: recording_4, created_at: now - 8.minutes)
      sentiment_5 = create(:sentiment, recording: recording_5, created_at: now - 10.days)
      sentiment_6 = create(:sentiment, recording: recording_6, created_at: now - 25.minutes)
      # rubocop:enable Lint/UselessAssignment

      @output = [
        {
          site: site_1,
          nps: [nps_1, nps_2],
          sentiment: [sentiment_1]
        },
        {
          site: site_2,
          nps: [nps_4],
          sentiment: [sentiment_4]
        },
        {
          site: site_3,
          nps: [nps_6],
          sentiment: [sentiment_6]
        }
      ]

      stub = double
      allow(stub).to receive(:deliver_now)
      allow(SiteMailer).to receive(:new_feedback).and_return(stub)
    end

    it 'sends the emails with the correct data' do
      subject

      expect(SiteMailer).to have_received(:new_feedback).with(@output[0], @output[0][:site].team[0].user)
      expect(SiteMailer).to have_received(:new_feedback).with(@output[0], @output[0][:site].team[1].user)
      expect(SiteMailer).to have_received(:new_feedback).with(@output[1], @output[1][:site].team[0].user)
      expect(SiteMailer).to have_received(:new_feedback).with(@output[2], @output[2][:site].team[0].user)
    end
  end
end
