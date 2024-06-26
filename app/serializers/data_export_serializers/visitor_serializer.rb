# frozen_string_literal: true

module DataExportSerializers
  class VisitorSerializer
    def initialize(visitor)
      @visitor = visitor
    end

    def serialize # rubocop:disable Metrics/AbcSize
      {
        id: visitor.id,
        visitor_id: visitor.visitor_id,
        status: visitor.viewed? ? 'Viewed' : 'New',
        first_viewed_at: Time.at(visitor.first_viewed_at / 1000).utc.iso8601,
        last_activity_at: Time.at(visitor.last_activity_at / 1000).utc.iso8601,
        user_id: linked_data_value(:id),
        name: linked_data_value(:name),
        email: linked_data_value(:email),
        languages: visitor.languages.uniq.sort.join('|'),
        browsers: visitor.browsers.uniq.sort.join('|'),
        country_codes: visitor.country_codes.join('|'),
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
  end
end
