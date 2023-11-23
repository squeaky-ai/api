# frozen_string_literal: true

module Resolvers
  module Events
    class Capture < Resolvers::Base
      type Types::Events::Capture, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 20
      argument :sort, Types::Events::CaptureSort, required: false, default_value: 'count__desc'
      argument :search, String, required: false, default_value: nil
      argument :filters, Types::Events::CaptureFilters, required: false, default_value: {}

      def resolve_with_timings(page:, size:, sort:, search:, filters:)
        events = object
          .event_captures
          .left_outer_joins(:event_groups) # So we can map &:name for #group_names
          .preload(:event_groups)

        events = search_names(events, search) if search
        events = filter_source(events, filters) if filters[:source]
        events = filter_event_type(events, filters) unless filters[:event_type].empty?

        events = events
          .order(order(sort))
          .page(page)
          .per(size)

        {
          items: events,
          pagination: {
            page_size: size,
            total: events.total_count,
            sort:
          }
        }
      end

      private

      def order(sort)
        sorts = {
          'name__asc' => 'name ASC',
          'name__desc' => 'name DESC',
          'count__asc' => 'count ASC',
          'count__desc' => 'count DESC'
        }
        sorts[sort]
      end

      def search_names(events, search)
        events.where(
          'LOWER(event_captures.name) LIKE :search OR LOWER(event_groups.name) LIKE :search',
          { search: "%#{search.downcase}%" }
        )
      end

      def filter_source(events, filters)
        if filters[:source] == 'web'
          # By default they are null
          events.where("source = 'web' OR source IS NULL")
        else
          events.where("source = 'api'")
        end
      end

      def filter_event_type(events, filters)
        events.where('event_type IN (?)', filters[:event_type])
      end
    end
  end
end
