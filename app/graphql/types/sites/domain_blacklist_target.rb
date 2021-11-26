# frozen_string_literal: true

module Types
  module Sites
    class DomainBlacklistTarget < Types::BaseEnum
      graphql_name 'SitesDomainBlacklistTarget'

      value 'domain', 'Blacklist a whole domain'
      value 'email', 'Blacklist an individual email'
    end
  end
end
