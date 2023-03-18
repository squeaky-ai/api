# frozen_string_literal: true

module Mutations
  module Exports
    class DataExportDelete < SiteMutation
      null true

      graphql_name 'DataExportDelete'

      argument :site_id, ID, required: true
      argument :data_export_id, ID, required: true

      type Types::Exports::DataExport

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve_with_timings(data_export_id:)
        data_export = site.data_exports.find(data_export_id)
        data_export.destroy

        nil
      end
    end
  end
end
