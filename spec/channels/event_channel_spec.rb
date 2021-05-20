# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, type: :channel do
  describe 'when a user subscribes' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    let(:status) { Recordings::Status.new(current_user) }

    it 'successfully subscribes' do
      stub_connection current_user: current_user
      subscribe
      expect(subscription).to be_confirmed
    end

    it 'sets the users recording status to active' do
      stub_connection current_user: current_user
      expect { subscribe }.to change { status.active? }.from(false).to(true)
    end
  end

  describe 'when a user unsubscribes' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    let(:status) { Recordings::Status.new(current_user) }

    it 'sets the users recording status to inactive' do
      stub_connection current_user: current_user
      subscribe
      expect { subscription.unsubscribe_from_channel }.to change { status.active? }.from(true).to(false)
    end
  end

  describe 'when a page_view is published' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:event) { new_recording_page_view }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    before { allow(Recordings::PageViewJob).to receive(:perform_later) }

    it 'hands the processing off to the PageView job' do
      stub_connection current_user: current_user
      subscribe

      perform :page_view, event
      expect(Recordings::PageViewJob).to have_received(:perform_later).with({ **event, **current_user })
    end
  end

  describe 'when a event is published' do
    let(:site_id) { Faker::Number.number(digits: 10) }
    let(:viewer_id) { SecureRandom.uuid }
    let(:session_id) { SecureRandom.uuid }
    let(:event) { new_recording_event }

    let(:current_user) do
      {
        site_id: site_id,
        viewer_id: viewer_id,
        session_id: session_id
      }
    end

    before { allow(Recordings::EventJob).to receive(:perform_later) }

    it 'hands the processing off to the Event job' do
      stub_connection current_user: current_user
      subscribe

      perform :event, event
      expect(Recordings::EventJob).to have_received(:perform_later).with({ **event, **current_user })
    end
  end
end
