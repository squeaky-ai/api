# frozen_string_literal: true

module Types
  # The nps scores items
  class NpsScoresExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      {
        trend: 0,
        responses: []
      }
    end
  end
end
