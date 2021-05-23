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

  def new_recording_event(args = {})
    default = {
      path: '/',
      locale: 'en-gb',
      useragent: Faker::Internet.user_agent,
      viewport_x: 0,
      viewport_y: 0,
      events: [
        {
          type: 'mouse',
          x: 0,
          y: 0,
          time: 0,
          timestamp: 0
        },
        {
          type: 'click',
          selector: 'body',
          time: 0,
          timestamp: 0
        }
      ]
    }
    { **default, **args }
  end

  def create_recording(args = {}, site:)
    default = {
      session_id: SecureRandom.uuid,
      viewer_id: SecureRandom.uuid,
      locale: 'en-gb',
      useragent: Faker::Internet.user_agent,
      viewport_x: 0,
      viewport_y: 0,
      page_views: ['/']
    }
    recording = Recording.create({ **default, **args })
    site.recordings << recording
    recording
  end

  def create_event(args = {}, recording:)
    event = Recordings::Event.new(
      site_id: recording.site.id,
      viewer_id: recording.viewer_id,
      session_id: recording.session_id
    )

    event.add(new_recording_event(args))
  end
end
