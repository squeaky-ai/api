# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'mailer.rake' do
  Rails.application.load_tasks

  ActiveJob::Base.queue_adapter = :test

  subject { Rake::Task['mailer'].invoke('ProductUpdatesMailer#january_2023') }

  let!(:user_1) { create(:site_with_team).owner.user }
  let!(:user_2) { create(:site_with_team).owner.user }
  let!(:user_3) { create(:site_with_team).owner.user }
  let!(:user_4) { create(:site_with_team).owner.user }
  let!(:user_5) { create(:site_with_team).owner.user }

  it 'sends the mailer to the users' do
    subject
    expect(ActionMailer::MailDeliveryJob)
      .to have_been_enqueued
      .with('ProductUpdatesMailer', 'january_2023', 'deliver_now', { args: [user_1] })
    expect(ActionMailer::MailDeliveryJob)
      .to have_been_enqueued
      .with('ProductUpdatesMailer', 'january_2023', 'deliver_now', { args: [user_2] })
    expect(ActionMailer::MailDeliveryJob)
      .to have_been_enqueued
      .with('ProductUpdatesMailer', 'january_2023', 'deliver_now', { args: [user_3] })
    expect(ActionMailer::MailDeliveryJob)
      .to have_been_enqueued
      .with('ProductUpdatesMailer', 'january_2023', 'deliver_now', { args: [user_4] })
    expect(ActionMailer::MailDeliveryJob)
      .to have_been_enqueued
      .with('ProductUpdatesMailer', 'january_2023', 'deliver_now', { args: [user_5] })
  end
end
