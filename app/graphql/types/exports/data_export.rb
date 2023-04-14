# typed: false
# frozen_string_literal: true

module Types
  module Exports
    class DataExport < Types::BaseObject
      graphql_name 'DataExport'

      field :id, ID, null: false
      field :filename, String, null: false
      field :export_type, Integer, null: false
      field :exported_at, Types::Common::Dates, null: true
      field :start_date, Types::Common::Dates, null: false
      field :end_date, Types::Common::Dates, null: false

      def exported_at
        DateFormatter.format(date: object.exported_at, timezone: context[:timezone])
      end

      def start_date
        DateFormatter.format(date: iso_date_string_to_date(object.start_date), timezone: context[:timezone])
      end

      def end_date
        DateFormatter.format(date: iso_date_string_to_date(object.end_date), timezone: context[:timezone])
      end

      private

      # Why did I make this column a string?
      def iso_date_string_to_date(date_string)
        return unless date_string

        year, month, day = date_string.split('-')
        Date.new(year.to_i, month.to_i, day.to_i)
      end
    end
  end
end
