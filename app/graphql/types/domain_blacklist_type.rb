# frozen_string_literal: true

module Types
  class DomainBlacklistType < Types::BaseObject
    description 'The domain blacklist object'

    field :type, DomainBlacklistTypeType, null: false
    field :value, String, null: false
  end
end
