# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, :type => :channel do
  let(:current_visitor) do
    {
      site_id: SecureRandom.uuid,
      visitor_id: SecureRandom.base36,
      session_id: SecureRandom.base36
    }
  end

  before do
    allow_any_instance_of(Aws::SQS::Client).to receive(:send_message)
  end

  it 'stores the events' do
    stub_connection current_visitor: current_visitor

    subscribe

    events_fixture = File.read("#{__dir__}/../fixtures/events.json")
    events = JSON.parse(events_fixture)

    events.each { |e| perform :event, **JSON.parse(e) }

    response = Redis.current.lrange("events::#{current_visitor[:site_id]}::#{current_visitor[:visitor_id]}::#{current_visitor[:session_id]}", 0, -1)

    expect(response.size).to eq events.size
  end
end
