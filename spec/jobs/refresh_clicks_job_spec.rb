# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RefreshClicksJob, type: :job do
  include ActiveJob::TestHelper

  subject { described_class.perform_now(Click) }

  before do
    allow(Click).to receive(:refresh).and_call_original
  end

  it 'refreshes the view' do
    subject
    expect(Click).to have_received(:refresh)
  end
end
