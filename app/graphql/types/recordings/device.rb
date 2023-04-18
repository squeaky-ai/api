# typed: false
# frozen_string_literal: true

module Types
  module Recordings
    class Device < Types::BaseObject
      graphql_name 'RecordingsDevice'

      field :browser_name, String, null: false
      field :browser_details, String, null: false
      field :viewport_x, Int, null: false
      field :viewport_y, Int, null: false
      field :device_x, Int, null: false
      field :device_y, Int, null: false
      field :device_type, String, null: false
      field :useragent, String, null: false
    end
  end
end
