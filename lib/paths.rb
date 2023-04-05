# frozen_string_literal: true

class Paths
  # Format a route:
  # /examples/:example
  # with something that the database can understand:
  # /examples/%
  def self.replace_route_with_wildcard(route)
    return route unless route.include?(':')

    route.split('/').map { |r| r.start_with?(':') ? '%' : r }.join('/')
  end

  def self.format_pages_with_routes(pages, routes)
    return pages if routes.empty?

    new.format_pages_with_routes(pages, routes)
  end

  def format_pages_with_routes(pages, routes)
    pages_with_routes = replace_page_urls_with_routes(pages, routes)

    combine_totals_for_pages(pages_with_routes)
  end

  private

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

  def combine_totals_for_pages(pages)
    pages.each_with_object([]) do |page, memo|
      exiting_index = memo.find_index { |m| m['url'] == page['url'] }

      if exiting_index
        memo[exiting_index]['count'] += page['count']
      else
        memo << page
      end
    end
  end
end
