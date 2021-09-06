# frozen_string_literal: true

module Types
  class DeviceType < Types::BaseObject
    description 'The device object'

    field :browser_name, String, null: false
    field :browser_details, String, null: false
    field :viewport_x, Int, null: false
    field :viewport_y, Int, null: false
    field :device_type, String, null: false
    field :useragent, String, null: false
  end
end
