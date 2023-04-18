# typed: false
# frozen_string_literal: true

module Resolvers
  module Events
    class Groups < Resolvers::Base
      type [Types::Events::Group, { null: false }], null: false

      def resolve_with_timings
        groups = object.event_groups
        captures = object.event_captures.joins(:event_groups).preload(:event_groups)

        group_items(groups, captures).sort { |a, b| a[:name] <=> b[:name] }
      end

      private

      def group_items(groups, items)
        groups.map do |group|
          {
            id: group.id,
            name: group.name,
            items: items.filter { |item| item.event_groups.map(&:id).include?(group.id) }.uniq(&:id)
          }
        end
      end
    end
  end
end
