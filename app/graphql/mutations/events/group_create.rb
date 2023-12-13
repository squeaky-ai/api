# frozen_string_literal: true

module Mutations
  module Events
    class GroupCreate < SiteMutation
      null false

      graphql_name 'EventGroupCreate'

      argument :site_id, ID, required: true
      argument :name, String, required: true

      type Types::Events::Group

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(name:)
        group = site.event_groups.find_or_create_by(name:)

        site.event_groups << group unless site.event_groups.include?(group)
        site.save

        group
      end
    end
  end
end
