# frozen_string_literal: true

module Mutations
  module Sites
    class AnonymisePreferencesUpdate < SiteMutation
      null false

      graphql_name 'AnonymisePreferencesUpdate'

      argument :site_id, ID, required: true
      argument :text_enabled, Boolean, required: true
      argument :forms_enabled, Boolean, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(text_enabled:, forms_enabled:, **_rest)
        @site.update(
          anonymise_form_inputs: forms_enabled,
          anonymise_text: text_enabled
        )

        SiteService.delete_cache(@user, @site.id)

        @site
      end
    end
  end
end
