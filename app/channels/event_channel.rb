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
    # Given that this part of the site is very write
    # heavy we hand it off to the job to be processed
    # in it's own time
    data.delete('action')
    event = Recordings::Event.validate!(data)
    EventHandlerJob.perform_later({ event: event, user: current_user }.deep_symbolize_keys!)
  end
end
