# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MaterializedViewRefreshJob, type: :job do
  include ActiveJob::TestHelper

  context 'when the table can be refreshed' do
    subject { described_class.perform_now(Click) }

    before do
      allow(Click).to receive(:refresh).and_call_original
    end

    it 'refreshes the view' do
      subject
      expect(Click).to have_received(:refresh)
    end

    it 'enqueues the job for the following day at 5am' do
      subject
      expect(described_class).to have_been_enqueued.with(Click).at(Time.now.next_day.beginning_of_day + 5.hours)
    end
  end

  context 'when the table can not be refreshed' do
    subject { described_class.perform_now(Click) }

    before do
      allow(Click).to receive(:refresh).and_raise NoMethodError
    end

    it 'raises an error' do
      expect { subject }.to raise_error(NoMethodError)
    end

    it 'does not enqueue another job' do
      expect(described_class).to_not have_been_enqueued
    end
  end
end
