# frozen_string_literal: true

class EventChannel < ApplicationCable::Channel
  periodically :check_ping, every: 10.seconds

  def subscribed
    Rails.logger.info "User connected #{current_visitor}"

    incr_active_user_counts!
  end

  def unsubscribed
    Rails.logger.info "User disconnected #{current_visitor}"

    decr_active_user_counts!

    # We only want one copy of the job in the queue
    # at once, or we'll process it multiple times
    delete_existing_job!

    # 30 minutes should give it enough time for us
    # to consider a user truly gone
    RecordingSaveJob.set(wait: 30.minutes).perform_later(
      'site_id' => site_uuid,
      'visitor_id' => visitor_id,
      'session_id' => session_id
    )

    Cache.redis.expire(session_key, 3600)
  end

  def event(data)
    # Manually sent by the client using perform('event)
    #
    # Do not ever make a DB connection in here!
    Cache.redis.lpush(session_key, compress_payload(data))
  end

  def ping
    # Manually sent by the client using perform('ping')
    #
    # Maintain our own "last_pinged_at" field so that
    # we can cut users off after a certain amount of
    # inactivity
    Cache.redis.hset('active_visitors', current_visitor, Time.current.to_i)
  end

  private

  def compress_payload(payload)
    deflate = Zlib::Deflate.new.deflate(payload.to_json, Zlib::FINISH)
    Base64.strict_encode64(deflate)
  end

  def incr_active_user_counts!
    Cache.redis.multi do |transaction|
      transaction.hset('active_visitors', current_visitor, Time.current.to_i)
      transaction.zincrby('active_user_count', 1, site_uuid)
    end
  end

  def decr_active_user_counts!
    count = Cache.redis.zscore('active_user_count', site_uuid)

    Cache.redis.multi do |transaction|
      transaction.hdel('active_visitors', current_visitor)
      transaction.zincrby('active_user_count', -1, site_uuid) if count.positive?
    end
  end

  def session_key
    "events::#{current_visitor}"
  end

  def site_uuid
    @site_uuid ||= current_visitor.split('::')[0]
  end

  def visitor_id
    @visitor_id ||= current_visitor.split('::')[1]
  end

  def session_id
    @session_id ||= current_visitor.split('::')[2]
  end

  def delete_existing_job!
    queue = Sidekiq::ScheduledSet.new

    queue.each do |job|
      args = job.args.first.to_h

      next unless args['job_class'] == 'RecordingSaveJob'

      # I can't find anyway of setting the job_id to something
      # that I could look up later, so this is the only way for
      # now
      job.delete if args['arguments'].to_s.include?(session_id)
    end
  end

  def check_ping
    connected_visitors = Cache.redis.hgetall('active_visitors')

    connected_visitors.each do |visitor_key, last_pinged_at|
      diff = Time.current.to_i - last_pinged_at.to_i

      next unless diff > 30 # seconds

      # Terminate this visitors' connection as they have
      # timed out (more than likely dropped already but
      # did not get picked up by the disconnect)
      ActionCable.server.remote_connections.where(current_visitor: visitor_key).disconnect(reconnect: false)
    end
  end
end
