# frozen_string_literal: true

class VisitorsCleanupJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    Visitor.find_each do |visitor|
      visitor.destroy if visitor.recordings.count.zero?
    end
  end
end
