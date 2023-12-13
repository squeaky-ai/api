# frozen_string_literal: true

module Mutations
  module Exports
    class DataExportCreate < SiteMutation
      null false

      graphql_name 'DataExportCreate'

      argument :site_id, ID, required: true
      argument :start_date, GraphQL::Types::ISO8601Date, required: true
      argument :end_date, GraphQL::Types::ISO8601Date, required: true
      argument :export_type, Integer, required: true

      type Types::Exports::DataExport

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(start_date:, end_date:, export_type:)
        data_export = DataExport.create!(
          site:,
          start_date:,
          end_date:,
          export_type:,
          filename: "#{DataExport.name_for_type(export_type)}-#{Time.current.to_i}.csv"
        )

        DataExportJob.perform_later(data_export.id)

        data_export
      end
    end
  end
end
