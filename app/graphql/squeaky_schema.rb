# frozen_string_literal: true

class SqueakySchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # Union and Interface Resolution
  def self.resolve_type(_abstract_type, _obj, _ctx)
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx); end

  # Given a string UUID, find the object
  def self.object_from_id(id, query_ctx); end
end
