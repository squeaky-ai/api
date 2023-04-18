# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventTrackingJob, type: :job do
  include ActiveJob::TestHelper

  let(:event) do
    {
      name: 'my-event',
      data: {}
    }
  end

  before do
    allow_any_instance_of(SqueakyClient).to receive(:add_event)
  end

  subject { described_class.perform_now(event) }

  it 'passes the event to the client' do
    expect_any_instance_of(SqueakyClient).to receive(:add_event).with(event)
    subject
  end
end
