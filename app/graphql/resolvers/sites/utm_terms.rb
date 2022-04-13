# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmTerms < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        utm_terms = Site
                    .find(object.id)
                    .recordings
                    .select(:utm_term)
                    .where('utm_term IS NOT NULL')
                    .distinct

        utm_terms.map(&:utm_term)
      end
    end
  end
end
