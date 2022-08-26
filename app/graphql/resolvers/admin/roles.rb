# frozen_string_literal: true

module Resolvers
  module Admin
    class Roles < Resolvers::Base
      type Types::Admin::Roles, null: false

      def resolve_with_timings
        roles = Team.select(:role).group(:role).count

        {
          owners: roles[Team::OWNER] || 0,
          admins: roles[Team::ADMIN] || 0,
          members: roles[Team::MEMBER] || 0,
          readonly: roles[Team::READ_ONLY] || 0
        }
      end
    end
  end
end
