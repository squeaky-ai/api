# frozen_string_literal: true

module Types
  module Sites
    class IpBlacklist < Types::BaseObject
      field :name, String, null: false
      field :value, String, null: false
    end
  end
end
