# frozen_string_literal: true

module Types
  class VisitorPagesCountType < Types::BaseObject
    description 'The visitors page views item'

    field :total, Integer, null: false
    field :unique, Integer, null: false
  end
end
