# frozen_string_literal: true

module Helpers
  def graphql_query(query, headers = {})
    params = { query: query, format: :json }

    headers['Accept'] = 'application/json'
    headers['Content-Type'] = 'application/json'

    post graphql_path, params: params.to_json, headers: headers
    JSON.parse(@response.body)
  end

  def create_user
    User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email)
  end

  def create_site
    Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
  end
end
