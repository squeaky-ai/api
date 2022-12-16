# frozen_string_literal: true

class VisitorSerializer
  def initialize(visitor)
    @visitor = visitor
  end

  def serialize # rubocop:disable Metrics/AbcSize
    {
      id: visitor.id,
      visitor_id: visitor.visitor_id,
      viewed: visitor.viewed,
      first_viewed_at: visitor.first_viewed_at.iso8601,
      last_activity_at: visitor.last_activity_at.iso8601,
      language: visitor.language,
      starred: visitor.starred,
      linked_data:,
      devices: visitor.devices,
      countries: visitor.countries,
      recording_count: visitor.recording_count[:total]
    }
  end

  private

  attr_reader :visitor

  def linked_data
    JSON.parse(visitor.linked_data, symbolize_names: true) if visitor.linked_data
  end
end
