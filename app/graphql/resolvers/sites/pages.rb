# frozen_string_literal: true

module Resolvers
  module Sites
    class Pages < Resolvers::Base
      type [Types::Sites::Page, { null: false }], null: false

      argument :from_date, GraphQL::Types::ISO8601Date, required: true
      argument :to_date, GraphQL::Types::ISO8601Date, required: true

      def resolve_with_timings(from_date:, to_date:)
        pages = pages(from_date, to_date)

        format_pages_with_routes(pages, object.routes)
      end

      private

      def pages(from_date, to_date)
        range = DateRange.new(from_date:, to_date:, timezone: context[:timezone])

        sql = <<-SQL
          SELECT
            url url,
            count(*) count
          FROM
            page_events
          WHERE
            site_id = :site_id AND
            toDate(exited_at / 1000, :timezone)::date BETWEEN :from_date AND :to_date
          GROUP BY
            url
          ORDER BY
            count DESC
        SQL

        variables = {
          site_id: object.id,
          timezone: range.timezone,
          from_date: range.from,
          to_date: range.to
        }

        Sql::ClickHouse.select_all(sql, variables)
      end

      def format_pages_with_routes(pages, routes)
        return pages if routes.empty?

        pages_with_routes = replace_page_urls_with_routes(pages, routes)

        pages_with_routes.each_with_object([]) do |page, memo|
          exiting_index = memo.find_index { |m| m['url'] == page['url'] }

          if exiting_index
            memo[exiting_index]['count'] += page['count']
          else
            memo << page
          end
        end
      end

      def replace_page_urls_with_routes(pages, routes)
        pages.map do |page|
          match = matching_route_for_page(routes, page)

          match ? { 'url' => match, 'count' => page['count'] } : page
        end
      end

      def matching_route_for_page(routes, page)
        routes.find do |route|
          route_chunks = route.split('/')
          # Trailing slashes are going to cause problems
          path_chunks = page['url'].sub(%r{/$}, '').split('/')

          if path_chunks.size == route_chunks.size
            parameter_indexes(route_chunks).each do |index|
              path_chunks.delete_at(index)
              route_chunks.delete_at(index)
            end

            route_chunks.join('/') == path_chunks.join('/')
          else
            false
          end
        end
      end

      def parameter_indexes(route_chunks)
        route_chunks.each_with_object([]).with_index do |(chunk, memo), index|
          memo.push(index) if chunk.start_with?(':')
          memo
        end
      end
    end
  end
end
