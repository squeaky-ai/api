# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, :type => :channel do
  let(:site_uuid) { SecureRandom.uuid }
  let(:visitor_id) { SecureRandom.base36 }
  let(:session_id) { SecureRandom.base36 }

  let(:current_visitor) do
    "#{site_uuid}::#{visitor_id}::#{session_id}"
  end

  let(:events_key) { "events::#{current_visitor}" }

  before(:each) do
    Cache.redis.del('active_visitors')
    Cache.redis.del('active_user_count')
  end

  describe '#subscribed' do
    before do
      # Add 5 users to the global count
      Cache.redis.zincrby('active_user_count', 5, site_uuid)
      # Add 2 users to the visitors count
      Cache.redis.hset('active_visitors', SecureRandom.uuid, Time.current.to_i)
      Cache.redis.hset('active_visitors', SecureRandom.uuid, Time.current.to_i)
    end

    it 'increments the global active user count' do
      stub_connection current_visitor: current_visitor

      expect { subscribe }.to change { Cache.redis.zscore('active_user_count', site_uuid).to_i }.from(5).to(6)
    end

    it 'increments the visitors count' do
      stub_connection current_visitor: current_visitor

      expect { subscribe }.to change { Cache.redis.hlen('active_visitors') }.from(2).to(3)
    end
  end

  describe '#unsubscribed' do

    it 'decrements the global active user count' do
      stub_connection current_visitor: current_visitor

      subscribe

      expect { subscription.unsubscribe_from_channel }.to change { Cache.redis.zscore('active_user_count', site_uuid).to_i }.from(1).to(0)
    end

    it 'decrements the visitors count' do
      stub_connection current_visitor: current_visitor

      subscribe

      expect { subscription.unsubscribe_from_channel }.to change { Cache.redis.hlen('active_visitors') }.from(1).to(0)
    end

    it 'sets the expiry on the events' do
      stub_connection current_visitor: current_visitor

      Cache.redis.lpush(events_key, "{}")

      subscribe
      subscription.unsubscribe_from_channel

      expect(Cache.redis.ttl(events_key)).to eq 3600
    end

    it 'enqueues the job' do
      stub_connection current_visitor: current_visitor

      ActiveJob::Base.queue_adapter = :test

      subscribe

      expect { subscription.unsubscribe_from_channel }.to have_enqueued_job(RecordingSaveJob).with(
        'site_id' => site_uuid,
        'visitor_id' => visitor_id,
        'session_id' => session_id
      )
    end

    context 'when there is a job enqueued already' do
      before do
        Sidekiq::ScheduledSet.new.each(&:delete)

        RecordingSaveJob.set(wait: 30.minutes).perform_later(
          'site_id' => site_uuid,
          'visitor_id' => visitor_id,
          'session_id' => session_id
        )
      end

      it 'deletes any existing jobs' do
        stub_connection current_visitor: current_visitor

        subscribe

        expect { subscription.unsubscribe_from_channel }.not_to change { Sidekiq::ScheduledSet.new.size }
      end
    end
  end

  describe '#event' do
    it 'stores the events' do
      stub_connection current_visitor: current_visitor

      subscribe

      events = require_fixture('events.json')

      events.each { |e| perform :event, **JSON.parse(e) }

      response = Cache.redis.lrange(events_key, 0, -1)

      expect(response.size).to eq events.size
    end
  end

  describe '#ping' do
    it 'updates the set time' do
      stub_connection current_visitor: current_visitor

      subscribe

      sleep 1 # We're only using second precision for the timeouts

      expect { perform :ping }.to change { Cache.redis.hget('active_visitors', current_visitor) }
    end
  end
end
