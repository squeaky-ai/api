# frozen_string_literal: true

class EventChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "User connected #{current_visitor}"
  end

  def unsubscribed
    Rails.logger.info "User disconnected #{current_visitor}"

    client = Aws::SQS::Client.new(region: 'eu-west-1')

    client.send_message(
      queue_url: ENV.fetch('RECORDINGS_SAVE_QUEUE_URL', 'QUEUE_MISSING'),
      message_body: current_visitor.to_json,
      message_group_id: session_key,
      message_deduplication_id: session_key
    )

    Redis.current.expire("events::#{session_key}", 3600)
  end

  def event(data)
    Redis.current.lpush("events::#{session_key}", data['payload'].to_json)
  end

  private

  def session_key
    [
      current_visitor[:site_id],
      current_visitor[:visitor_id],
      current_visitor[:session_id]
    ].join('::')
  end
end
