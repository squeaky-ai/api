# frozen_string_literal: true

module Types
  module Sites
    class DomainBlacklist < Types::BaseObject
      field :type, Types::Site::DomainBlacklistType, null: false
      field :value, String, null: false
    end
  end
end
