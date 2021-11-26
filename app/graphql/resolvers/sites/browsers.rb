# frozen_string_literal: true

module Resolvers
  module Sites
    class Browsers < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve
        browsers = Site
                   .find(object.id)
                   .recordings
                   .select(:useragent, :viewport_x, :viewport_y, :device_x, :device_y)

        browsers.map { |b| b.device[:browser_name] }.uniq
      end
    end
  end
end
