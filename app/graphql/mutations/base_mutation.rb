# frozen_string_literal: true

module Mutations
  class BaseMutation < GraphQL::Schema::RelayClassicMutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    input_object_class Types::BaseInputObject
    object_class Types::BaseObject

    def resolve(*, **kwargs)
      unless respond_to?(:resolve_with_timings)
        raise GraphQL::RequiredImplementationMissingError, "#{self.class.name}#resolve should execute the field's logic"
      end

      Stats.timer(self.class) do
        # We assign the site as an instance varaible
        # so there's no point in passing the site_id
        # around
        kwargs.delete(:site_id) if kwargs[:site_id] && site_mutation?

        resolve_with_timings(*, **kwargs)
      end
    end

    private

    def site_mutation?
      self.class.ancestors.include?(Mutations::SiteMutation)
    end
  end
end
