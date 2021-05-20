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
  #   data: '{"action":"page_view", "href": "/", "locale": "en-gb", "useragent": "...", "timestamp": 000000000}'
  # }
  def page_view(data)
    data.delete('action')
    Recordings::PageView.validate!(data)
    Recordings::PageViewJob.perform_later({ **data, **current_user }.deep_symbolize_keys!)
  end

  # {
  #   command: 'message',
  #   identifier: '{"channel":"EventChannel"}'
  #   data: '{"action":"event", "position": 0, "mouse_x": 0, "mouse_y": 0, ...}'
  # }
  def event(data)
    data.delete('action')
    Recordings::Event.validate!(data)
    Recordings::EventJob.perform_later({ **data, **current_user }.deep_symbolize_keys!)
  end
end
