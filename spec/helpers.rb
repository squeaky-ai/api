# frozen_string_literal: true

module Helpers
  def graphql_request(query, variables, user)
    SqueakySchema.execute(query, context: { current_user: user }, variables: variables)
  end

  def create_user(args = {})
    default = {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email
    }
    User.create({ **default, **args })
  end

  def create_site(args = {})
    default = {
      name: Faker::Company.name,
      url: Faker::Internet.url,
      plan: 0
    }
    Site.create({ **default, **args })
  end

  def create_team(user:, site:, role:, status: 0)
    Team.create(user: user, site: site, role: role, status: status)
  end

  def create_site_and_team(user, role: 2, status: 0)
    site = create_site
    site.team << create_team(user: user, site: site, role: role, status: status)
    site.save
    site
  end
end
