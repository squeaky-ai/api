# frozen_string_literal: true

module Types
  # Pages by a particular visitor
  class VisitorPagesExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 10, description: 'The page size')
      field.argument(:sort, VisitorPagesSortType, required: false, default_value: 'VIEWS_COUNT_DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      order = order_by(arguments[:sort])
      visitor_id = object.object[:id]

      pages = Visitor
              .find(visitor_id)
              .pages
              .select('url, count(*) count')
              .group(:url)
              .order(order)
              .page(arguments[:page])
              .per(arguments[:size])

      {
        items: map_results(pages),
        pagination: pagination(arguments, pages, arguments[:size])
      }
    end

    def pagination(arguments, pages, size)
      {
        page_size: size,
        total: pages.total_count,
        sort: arguments[:sort]
      }
    end

    private

    def map_results(pages)
      pages.to_a.map do |page|
        {
          page_view: page.url,
          page_view_count: page.count,
          average_time_on_page: 0
        }
      end
    end

    def order_by(sort)
      orders = {
        'VIEWS_COUNT_DESC' => 'count DESC',
        'VIEWS_COUNT_ASC' => 'count ASC'
      }

      Arel.sql(orders[sort] || orders['VIEWS_COUNT_DESC'])
    end
  end
end
