# frozen_string_literal: true

module Mutations
  module Sites
    class Delete < SiteMutation
      null true

      graphql_name 'SitesDelete'

      argument :site_id, ID, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER]
      end

      def resolve(**_args)
        # Send an email to everyone in the team besides the owner
        @site.team.each { |t| SiteMailer.destroyed(t.user.email, @site).deliver_now unless t.owner? }
        @site.destroy

        nil
      end
    end
  end
end
