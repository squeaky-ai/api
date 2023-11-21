# frozen_string_literal: true

class EventChannel < ApplicationCable::Channel
  periodically :check_ping, every: 10.seconds

  delegate :site_id, :visitor_id, :session_id, to: :current_visitor

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
      'site_id' => site_id,
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
    Cache.redis.hset(site_active_user_count_key, visitor_id, Time.now.to_i)
  end

  private

  def compress_payload(payload)
    deflate = Zlib::Deflate.new.deflate(payload.to_json, Zlib::FINISH)
    Base64.strict_encode64(deflate)
  end

  def incr_active_user_counts!
    Cache.redis.multi do |transaction|
      transaction.hset(site_active_user_count_key, visitor_id, Time.now.to_i)
      transaction.zincrby(global_active_user_count_key, 1, site_id)
    end
  end

  def decr_active_user_counts!
    count = Cache.redis.zscore(global_active_user_count_key, site_id)

    Cache.redis.multi do |transaction|
      transaction.hdel(site_active_user_count_key, visitor_id)
      transaction.zincrby(global_active_user_count_key, -1, site_id) if count.positive?
    end
  end

  def session_key
    ['events', site_id, visitor_id, session_id].join('::')
  end

  def delete_existing_job!
    queue = Sidekiq::ScheduledSet.new

    queue.each do |job|
      args = job.args.first.to_h

      next unless args['job_class'] == 'RecordingSaveJob'

      puts "DEBUG is there a job already for #{session_id} in #{args['arguments']}?"

      # I can't find anyway of setting the job_id to something
      # that I could look up later, so this is the only way for
      # now
      job.delete if args['arguments'].to_s.include?(session_id)
    end
  end

  def global_active_user_count_key
    'active_user_count'
  end

  def site_active_user_count_key
    "active_user_count::#{site_id}"
  end

  def check_ping
    Rails.logger.info 'Checking which visitors need terminating'
    # puts '!!!!', ActionCable.server.remote_connections.where(current_visitor: 'dfgfgfgd').disconnected(reconnect: false)

    # connected_visitors = Cache.redis.hgetall(site_active_user_count_key)

    # connected_visitors.each do |visitor_id, last_pinged_at|
    #   diff = Time.now.to_i > last_pinged_at.to_i

    #   puts "Should kill #{visitor_id}" if diff > 10
    # end
  end
end
