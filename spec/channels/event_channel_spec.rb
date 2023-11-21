# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventChannel, :type => :channel do
  let(:current_visitor) do
    hash = {
      site_id: SecureRandom.uuid,
      visitor_id: SecureRandom.base36,
      session_id: SecureRandom.base36
    }

    Struct.new(*hash.keys).new(*hash.values)
  end

  let(:events_key) { "events::#{current_visitor.site_id}::#{current_visitor.visitor_id}::#{current_visitor.session_id}" }

  describe '#subscribed' do
    before do
      # Add 5 users to the global count
      Cache.redis.zincrby('active_user_count', 5, current_visitor.site_id)
      # Add 2 users to the site level count
      Cache.redis.hset("active_user_count::#{current_visitor.site_id}", SecureRandom.uuid, Time.now.to_i)
      Cache.redis.hset("active_user_count::#{current_visitor.site_id}", SecureRandom.uuid, Time.now.to_i)
    end

    it 'increments the global active user count' do
      stub_connection current_visitor: current_visitor

      expect { subscribe }.to change { Cache.redis.zscore('active_user_count', current_visitor.site_id).to_i }.from(5).to(6)
    end

    it 'increments the site level active user count' do
      stub_connection current_visitor: current_visitor

      expect { subscribe }.to change { Cache.redis.hlen("active_user_count::#{current_visitor.site_id}") }.from(2).to(3)
    end
  end

  describe '#unsubscribed' do

    it 'decrements the global active user count' do
      stub_connection current_visitor: current_visitor

      subscribe

      expect { subscription.unsubscribe_from_channel }.to change { Cache.redis.zscore('active_user_count', current_visitor.site_id).to_i }.from(1).to(0)
    end

    it 'decrements the site level active user count' do
      stub_connection current_visitor: current_visitor

      subscribe

      expect { subscription.unsubscribe_from_channel }.to change { Cache.redis.hlen("active_user_count::#{current_visitor.site_id}") }.from(1).to(0)
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
        'site_id' => current_visitor.site_id,
        'visitor_id' => current_visitor.visitor_id,
        'session_id' => current_visitor.session_id
      )
    end

    context 'when there is a job enqueued already' do
      before do
        Sidekiq::ScheduledSet.new.each(&:delete)
        RecordingSaveJob.set(wait: 30.minutes).perform_later(
          'site_id' => current_visitor.site_id,
          'visitor_id' => current_visitor.visitor_id,
          'session_id' => current_visitor.session_id
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

      expect { perform :ping }.to change { Cache.redis.hget("active_user_count::#{current_visitor.site_id}", current_visitor.visitor_id) }
    end
  end
end
