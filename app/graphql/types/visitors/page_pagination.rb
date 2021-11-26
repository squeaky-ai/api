# frozen_string_literal: true

module Types
  module Visitors
    class PagePagination < Types::BaseObject
      graphql_name 'VisitorsPagePagination'

      field :page_size, Integer, null: false
      field :total, Integer, null: false
      field :sort, Types::Visitors::PagesSort, null: false
    end
  end
end
