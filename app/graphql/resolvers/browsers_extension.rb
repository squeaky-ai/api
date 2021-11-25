# frozen_string_literal: true

module Types
  class BrowsersExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      browsers = Site
                 .find(object.object['id'])
                 .recordings
                 .select(:useragent, :viewport_x, :viewport_y, :device_x, :device_y)

      browsers.map { |b| b.device[:browser_name] }.uniq
    end
  end
end
