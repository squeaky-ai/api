# frozen_string_literal: true

module DataExportSerializers
  class VisitorSerializer
    def initialize(visitor)
      @visitor = visitor
    end

    def serialize
      {
        id: visitor.id,
        visitor_id: visitor.visitor_id,
        status: viewed? ? 'Viewed' : 'New',
        first_viewed_at:,
        last_activity_at:,
        user_id: linked_data_value(:id),
        name: linked_data_value(:name),
        email: linked_data_value(:email),
        languages: languages.uniq.sort.join('|'),
        browsers: browsers.uniq.sort.join('|'),
        country_codes: country_codes.join('|'),
        recording_count: visitor.recordings_count,
        source: visitor.source
      }
    end

    private

    attr_reader :visitor

    def linked_data_value(key)
      return nil unless linked_data

      linked_data[key.to_sym]
    end

    def linked_data
      @linked_data ||= JSON.parse(visitor.linked_data, symbolize_names: true) if visitor.linked_data
    end

    def viewed?
      recordings.filter(&:viewed).size.positive?
    end

    def recordings
      @recordings ||= Recording.where('visitor_id = ?', visitor.id)
    end

    def first_viewed_at
      first_event = recordings.min_by(&:connected_at)
      timestamp = first_event&.connected_at

      return unless timestamp

      Time.at(timestamp / 1000).utc.iso8601
    end

    def last_activity_at
      last_event = recordings.max_by(&:disconnected_at)
      timestamp = last_event&.disconnected_at

      return unless timestamp

      Time.at(timestamp / 1000).utc.iso8601
    end

    def browsers
      recordings.filter(&:browser).map(&:browser)
    end

    def languages
      recordings.filter(&:language).map(&:language)
    end

    def country_codes
      recordings.map(&:country_code).compact.uniq
    end
  end
end
