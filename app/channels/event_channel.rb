# frozen_string_literal: true

# When users visit a customers site it will open a websocket
# connection that is handled by this class. We create a
# websocket session in the database and store the events that
# are fed from the FE
class EventChannel < ApplicationCable::Channel
  # {
  #   command: 'subscribe',
  #   identifier: '{"channel":"EventChannel"}'
  # }
  def subscribed
    Recordings::Status.new(current_user).active!
  end

  # {
  #   command: 'unsubscribe',
  #   identifier: '{"channel":"EventChannel"}'
  # }
  def unsubscribed
    Recordings::Status.new(current_user).inactive!
  end

  # {
  #   command: 'message',
  #   identifier: '{"channel":"EventChannel"}'
  #   data: '{"action":"page_view"}'
  # }
  def event(data)
    puts '@@', data
  end

  private

  def key
    "#{current_user[:site_id]}:#{current_user[:session_id]}:#{current_user[:viewer_id]}"
  end
end
