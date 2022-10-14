# frozen_string_literal: true

class RecordingDeleteJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(recording_id)
    @recording = Recording.find(recording_id)
    @site = recording.site

    delete_recording_events
    delete_postgres_events
    # delete_clickhouse_events TODO: when on clickhouse:22.9
    delete_recording
  end

  private

  attr_reader :recording, :site

  def delete_recording_events
    RecordingEventsService.delete(recording:)
  end

  def delete_postgres_events
    # TODO: Remove when there are none left
    Event.where('recording_id = ?', recording.id).delete_all
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
    ].each { |c| c.delete_from_recording(recording) }
  end

  def delete_recording
    recording.destroy
  end
end
