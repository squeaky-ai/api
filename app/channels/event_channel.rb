# frozen_string_literal: true

class EventChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "User connected #{current_visitor}"

    incr_active_user_count!
  end

  def unsubscribed
    Rails.logger.info "User disconnected #{current_visitor}"

    decr_active_user_count!
    # We only want one copy of the job in the queue
    # at once, or we'll process it multiple times
    delete_existing_job!

    # 30 minutes should give it enough time for us
    # to consider a user truly gone
    RecordingSaveJob.set(wait: 30.minutes).perform_later(current_visitor)

    Cache.redis.expire("events::#{session_key}", 3600)
  end

  def event(data)
    Cache.redis.lpush("events::#{session_key}", compress_payload(data))
  end

  private

  def compress_payload(payload)
    deflate = Zlib::Deflate.new.deflate(payload.to_json, Zlib::FINISH)
    Base64.strict_encode64(deflate)
  end

  def incr_active_user_count!
    Cache.redis.zincrby('active_user_count', 1, current_visitor[:site_id])
  end

  def decr_active_user_count!
    count = Cache.redis.zscore('active_user_count', current_visitor[:site_id])

    Cache.redis.zincrby('active_user_count', -1, current_visitor[:site_id]) if count.positive?
  end

  def session_key
    [
      current_visitor[:site_id],
      current_visitor[:visitor_id],
      current_visitor[:session_id]
    ].join('::')
  end

  def delete_existing_job!
    queue = Sidekiq::Queue.new('default')

    queue.each { |job| job.delete if job.jid == session_key }
  end
end
