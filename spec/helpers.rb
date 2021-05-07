# frozen_string_literal: true

module Helpers
  def graphql_query(query, variables, user)
    SqueakySchema.execute(query, context: { current_user: user }, variables: variables)
  end

  def create_user
    User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email)
  end

  def create_site
    Site.create(name: Faker::Company.name, url: Faker::Internet.url, plan: 0)
  end

  def create_team(user:, site:, role:)
    Team.create(user: user, site: site, role: role)
  end
end
