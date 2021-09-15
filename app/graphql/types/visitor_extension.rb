# frozen_string_literal: true

module Types
  # Get a single visitor by their visitor_id
  class VisitorExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:visitor_id, GraphQL::Types::ID, required: true, description: 'The id of the visitor')
    end

    def resolve(object:, arguments:, **_rest)
      site_id = object.object[:id]
      visitor_id = arguments[:visitor_id]

      Visitor
        .eager_load(:recordings, :pages)
        .where('recordings.site_id = ? AND visitors.id = ?', site_id, visitor_id)
        .first
    end
  end
end
