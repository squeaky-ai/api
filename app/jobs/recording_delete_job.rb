# frozen_string_literal: true

class RecordingDeleteJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(recording_ids)
    @recordings = Recording.where(id: recording_ids)

    @visitor_ids = recordings.map(&:visitor_id)
    @recording_ids = recording_ids

    return if @recordings.empty?

    delete_recordings_events
    delete_clickhouse_events
    delete_recordings
    delete_visitors
  end

  private

  attr_reader :recording_ids, :visitor_ids, :recordings

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

  def delete_visitors
    # I messed with the idea of joining recordings
    # to visitors but I think this is the quickest
    # way to work out if a visitor has no recordings
    sql = <<-SQL.squish
      SELECT DISTINCT(visitor_id)
      FROM recordings
      WHERE visitor_id IN (?)
    SQL

    visitor_ids_with_recordings = Sql.execute(sql, [visitor_ids]).map { |v| v['visitor_id'] }
    visitor_ids_to_delete = visitor_ids.filter { |v| !visitor_ids_with_recordings.include?(v) }

    Visitor.where(id: visitor_ids_to_delete).destroy_all
  end
end
