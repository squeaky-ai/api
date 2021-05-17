# frozen_string_literal: true

class EventChannel < ApplicationCable::Channel
  def subscribed
    puts '@@ sub', current_user
  end

  def unsubscribed
    puts '@@ unsub'
  end
end
