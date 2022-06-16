# frozen_string_literal: true

module Mutations
  module Events
    class CaptureCreate < SiteMutation
      null false

      graphql_name 'EventCaptureCreate'

      argument :site_id, ID, required: true
      argument :type, Int, required: true
      argument :name, String, required: true
      argument :rules, [Types::Events::RuleInput], required: true
      argument :group_ids, [Int], required: true

      type Types::Events::CaptureItem

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(type:, name:, rules:, group_ids:, **_rest)
        groups = EventGroup.where(id: group_ids, site_id: @site.id)

        event = EventCapture.create(
          name:,
          rules:,
          event_type: type,
          site: @site,
          event_groups: groups
        )

        event
      end
    end
  end
end
