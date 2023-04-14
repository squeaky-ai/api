# typed: false
# frozen_string_literal: true

module Types
  module Visitors
    class Page < Types::BaseObject
      graphql_name 'VisitorsPage'

      field :page_view, String, null: false
      field :page_view_count, Integer, null: false
      field :average_time_on_page, Integer, null: false
    end
  end
end
