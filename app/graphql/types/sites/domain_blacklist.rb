# frozen_string_literal: true

module Types
  module Sites
    class DomainBlacklist < Types::BaseObject
      field :type, Types::Sites::DomainBlacklistTarget, null: false
      field :value, String, null: false
    end
  end
end
