# frozen_string_literal: true

class RecordingDeleteJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(recording_ids)
    @recording_ids = recording_ids
    @recordings = Recording.where(id: recording_ids)

    return if @recordings.empty?

    delete_recordings_events
    delete_clickhouse_events
    delete_recordings
  end

  private

  attr_reader :recording_ids, :recordings

  def delete_recordings_events
    # TODO: Can this be batched?
    recordings.each do |recording|
      RecordingEventsService.delete(recording:)
    end
  end

  def delete_clickhouse_events
    [
      ClickHouse::ClickEvent,
      ClickHouse::CursorEvent,
      ClickHouse::CustomEvent,
      ClickHouse::ErrorEvent,
      ClickHouse::PageEvent,
      ClickHouse::Recording,
      ClickHouse::ScrollEvent
    ].each { |c| c.delete_from_recordings(recording_ids:) }
  end

  def delete_recordings
    recordings.destroy_all
  end
end
