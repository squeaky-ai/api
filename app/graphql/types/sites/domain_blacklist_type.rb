# frozen_string_literal: true

module Types
  module Sites
    class DomainBlacklistType < Types::BaseEnum
      value 'domain', 'Blacklist a whole domain'
      value 'email', 'Blacklist an individual email'
    end
  end
end
