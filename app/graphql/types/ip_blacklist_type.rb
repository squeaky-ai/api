# frozen_string_literal: true

module Types
  class IpBlacklistType < Types::BaseObject
    description 'The IP blacklist object'

    field :name, String, null: false
    field :value, String, null: false
  end
end
