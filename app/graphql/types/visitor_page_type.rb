# frozen_string_literal: true

module Types
  class VisitorPageType < Types::BaseObject
    description 'The visitor page object'

    field :page_view, String, null: false
    field :page_view_count, Integer, null: false
    field :average_time_on_page, Integer, null: false
  end
end
