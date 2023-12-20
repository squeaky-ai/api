# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyReviewEmailsJob, type: :job, truncate_click_house: true do
  include ActiveJob::TestHelper

  let(:today) { Time.zone.today }
  let(:last_week) { Time.zone.today - 1.week }

  let!(:site_1) { create(:site) }
  let!(:site_2) { create(:site) }
  let!(:site_3) { create(:site) }

  let(:site_1_team_1) { create(:team, site: site_1, role: Team::MEMBER) }
  let(:site_2_team_1) { create(:team, site: site_2, role: Team::MEMBER) }
  let(:site_3_team_1) { create(:team, site: site_3, role: Team::MEMBER) }
  let(:site_3_team_2) { create(:team, site: site_3, role: Team::ADMIN) }

  let(:site_1_data_hash) { {} }
  let(:site_2_data_hash) { {} }
  let(:site_3_data_hash) { {} }

  let(:site_2_weekly_service) do
    instance_double(
      WeeklyReviewService::Generator,
      site: site_2,
      members: [site_2_team_1],
      to_h: site_2_data_hash
    )
  end

  let(:site_3_weekly_service) do
    instance_double(
      WeeklyReviewService::Generator,
      site: site_3,
      members: [site_3_team_1, site_3_team_2],
      to_h: site_3_data_hash
    )
  end

  before do
    allow(SiteMailer).to receive(:weekly_review).and_call_original

    allow(WeeklyReviewService::Generator).to receive(:new)
      .with(
        site_id: site_2.id,
        from_date: last_week.beginning_of_week,
        to_date: last_week.end_of_week
      )
      .and_return(site_2_weekly_service)

    allow(WeeklyReviewService::Generator).to receive(:new)
      .with(
        site_id: site_3.id,
        from_date: last_week.beginning_of_week,
        to_date: last_week.end_of_week
      )
      .and_return(site_3_weekly_service)

    ClickHouse::Recording.insert do |buffer|
      buffer << {
        uuid: SecureRandom.uuid,
        site_id: site_1.id,
        disconnected_at: (last_week - 1.week).to_time.to_i * 1000
      }
      buffer << {
        uuid: SecureRandom.uuid,
        site_id: site_2.id,
        disconnected_at: last_week.to_time.to_i * 1000
      }
      buffer << {
        uuid: SecureRandom.uuid,
        site_id: site_3.id,
        disconnected_at: last_week.to_time.to_i * 1000
      }
    end
  end

  subject { described_class.perform_now }

  it 'triggers the emails for all sites that qualify' do
    subject

    expect(site_2_weekly_service).to have_received(:to_h).once
    expect(site_3_weekly_service).to have_received(:to_h).twice

    # Site 1 only had recordings in the previous week
    expect(SiteMailer).not_to have_received(:weekly_review).with(site_1, site_1_data_hash, site_1_team_1.user)
    # Site 2 had recordings in the time period, with one team member
    expect(SiteMailer).to have_received(:weekly_review).with(site_2, site_2_data_hash, site_2_team_1.user)
    # Site 3 had recordings in the time period, with two team members
    expect(SiteMailer).to have_received(:weekly_review).with(site_3, site_3_data_hash, site_3_team_1.user)
    expect(SiteMailer).to have_received(:weekly_review).with(site_3, site_3_data_hash, site_3_team_2.user)
  end
end
