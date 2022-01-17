# frozen_string_literal: true

module Resolvers
  module Sites
    class CountryCodes < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        country_codes = Site
                        .find(object.id)
                        .recordings
                        .select(:country_code)
                        .where('country_code IS NOT NULL')

        country_codes.map(&:country_code).uniq
      end
    end
  end
end
