# frozen_string_literal: true

module Resolvers
  module Sites
    class Languages < Resolvers::Base
      def resolve
        languges = Site
                  .find(object.id)
                  .recordings
                  .select(:locale)

        languges.map(&:language).uniq
      end
    end
  end
end
