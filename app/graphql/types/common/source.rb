# typed: false
# frozen_string_literal: true

module Types
  module Common
    class Source < Types::BaseEnum
      graphql_name 'Source'

      value 'api', 'Record was created using the public API'
      value 'web', 'Record was created using the session'
    end
  end
end
