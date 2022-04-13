# frozen_string_literal: true

module Resolvers
  module Sites
    class UtmContents < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        utm_contents = Site
                       .find(object.id)
                       .recordings
                       .select(:utm_content)
                       .where('utm_content IS NOT NULL')
                       .distinct

        utm_contents.map(&:utm_content)
      end
    end
  end
end
