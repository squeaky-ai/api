# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmSources < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        utm_sources = Site
                      .find(object.id)
                      .recordings
                      .select(:utm_source)
                      .where('utm_source IS NOT NULL')
                      .distinct

        utm_sources.map(&:utm_source)
      end
    end
  end
end
