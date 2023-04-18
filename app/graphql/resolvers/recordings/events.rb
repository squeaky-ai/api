# typed: false
# frozen_string_literal: true

module Resolvers
  module Recordings
    class Events < Resolvers::Base
      type Types::Recordings::Events, null: true

      argument :page, Integer, required: false, default_value: 1

      def resolve_with_timings(page:)
        files = RecordingEventsService.list(recording: object)

        return nil if files.empty?

        {
          items: RecordingEventsService.get(recording: object, filename: files[page - 1]),
          pagination: pagination(files)
        }
      end

      private

      def pagination(files)
        {
          current_page: arguments[:page],
          total_pages: files.size
        }
      end
    end
  end
end
