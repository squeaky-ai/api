# frozen_string_literal: true

module Helpers
  def graphql_query(query, headers = {})
    params = { query: query, format: :json }

    headers['Accept'] = 'application/json'
    headers['Content-Type'] = 'application/json'

    post graphql_path, params: params.to_json, headers: headers
    JSON.parse(@response.body)
  end
end
