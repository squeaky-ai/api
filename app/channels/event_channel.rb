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
  #   data: '{"action":"event", "events": [], ...}'
  # }
  def event(data)
    data.delete('action')
    Recordings::Event.validate!(data)
    Recordings::EventJob.perform_later({ **data, **current_user }.deep_symbolize_keys!)
  end
end
