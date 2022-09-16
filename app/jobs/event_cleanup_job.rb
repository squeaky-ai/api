# frozen_string_literal: true

class EventCleanupJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    Event.select(:id).where('id BETWEEN ? AND ?', 200_000_000, 416_820_604).in_batches(of: 50_000) do |ids|
      Event.where(id: ids).delete_all
    end
  end
end
