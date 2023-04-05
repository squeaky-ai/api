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
end
