# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, :type => :channel do
  describe '#subscribed' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    let(:redis_key) { "active_user_count::#{current_visitor[:site_id]}" }

    before do
      Redis.current.set(redis_key, '5')
    end

    it 'increments the active user count' do
      stub_connection current_visitor: current_visitor

      expect { subscribe }.to change { Redis.current.get(redis_key) }.from('5').to('6')
    end
  end

  describe '#unsubscribed' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    let(:active_visitor_key) { "active_user_count::#{current_visitor[:site_id]}" }
    let(:events_key) { "events::#{current_visitor[:site_id]}::#{current_visitor[:visitor_id]}::#{current_visitor[:session_id]}" }

    it 'decrements the active user count' do
      stub_connection current_visitor: current_visitor

      subscribe

      expect { subscription.unsubscribe_from_channel }.to change { Redis.current.get(active_visitor_key) }.from('1').to('0')
    end

    it 'sets the expiry on the events' do
      stub_connection current_visitor: current_visitor

      Redis.current.lpush(events_key, "{}")

      subscribe
      subscription.unsubscribe_from_channel

      expect(Redis.current.ttl(events_key)).to eq 3600
    end

    it 'enqueues the job' do
      stub_connection current_visitor: current_visitor

      ActiveJob::Base.queue_adapter = :test

      subscribe

      expect { subscription.unsubscribe_from_channel }.to have_enqueued_job(RecordingSaveJob).with(current_visitor)
    end
  end

  describe '#event' do
    let(:current_visitor) do
      {
        site_id: SecureRandom.uuid,
        visitor_id: SecureRandom.base36,
        session_id: SecureRandom.base36
      }
    end

    let(:events_key) { "events::#{current_visitor[:site_id]}::#{current_visitor[:visitor_id]}::#{current_visitor[:session_id]}" }

    it 'stores the events' do
      stub_connection current_visitor: current_visitor

      subscribe

      events_fixture = File.read("#{__dir__}/../fixtures/events.json")
      events = JSON.parse(events_fixture)

      events.each { |e| perform :event, **JSON.parse(e) }

      response = Redis.current.lrange(events_key, 0, -1)

      expect(response.size).to eq events.size
    end
  end
end
