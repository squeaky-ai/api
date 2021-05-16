# frozen_string_literal: true

require 'securerandom'

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
      plan: Site::ESSENTIALS
    }
    Site.create({ **default, **args })
  end

  def create_team(user:, site:, role:, status: Team::ACCEPTED)
    Team.create(user: user, site: site, role: role, status: status)
  end

  def create_site_and_team(user:, role: Team::OWNER, status: Team::ACCEPTED)
    site = create_site
    site.team << create_team(user: user, site: site, role: role, status: status)
    site.save
    site
  end

  def create_recording(args = {}, site:)
    default = {
      session_id: SecureRandom.uuid,
      viewer_id: SecureRandom.uuid,
      locale: 'en-gb',
      start_page: '/',
      exit_page: '/',
      useragent: Faker::Internet.user_agent,
      viewport_x: 1920,
      viewport_y: 1080,
      page_views: ['/']
    }
    site.recordings << Recording.create({ **default, **args })
  end
end
