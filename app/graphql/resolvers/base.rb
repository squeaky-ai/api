# frozen_string_literal: true

module Resolvers
  class Base < GraphQL::Schema::Resolver
    def resolve(*, **)
      unless respond_to?(:resolve_with_timings)
        raise GraphQL::RequiredImplementationMissingError, "#{self.class.name}#resolve should execute the field's logic"
      end

      Stats.timer(self.class) do
        resolve_with_timings(*, **)
      end
    end
  end
end
