# frozen_string_literal: true

class RefreshClicksJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    Click.refresh
  end
end
