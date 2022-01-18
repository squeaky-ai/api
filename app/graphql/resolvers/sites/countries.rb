# frozen_string_literal: true

module Resolvers
  module Sites
    class Countries < Resolvers::Base
      type [Types::Recordings::Country, { null: true }], null: false

      def resolve
        country_codes = Site
                        .find(object.id)
                        .recordings
                        .select('country_code, COUNT(country_code)')
                        .where('country_code IS NOT NULL')
                        .group('country_code')

        country_codes.map do |code|
          {
            code: code.country_code,
            name: code.country_name,
            count: code.count
          }
        end
      end
    end
  end
end
