# frozen_string_literal: true

require 'date'
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
      site_id: site.uuid,
      session_id: SecureRandom.uuid,
      viewer_id: SecureRandom.uuid,
      locale: 'en-GB',
      start_page: '/',
      exit_page: '/',
      useragent: Faker::Internet.user_agent,
      viewport_x: 0,
      viewport_y: 0,
      active: 0,
      connected_at: DateTime.now.iso8601,
      disconnected_at: DateTime.now.iso8601
    }
    recording = Recording.new({ **default, **args })
    recording.save!
    recording
  end

  def create_event(args = {}, recording:)
    default = {
      site_session_id: recording.event_key,
      event_id: SecureRandom.uuid,
      type: 'cursor',
      x: 0,
      y: 0,
      time: 0,
      timestamp: 0
    }
    event = Event.new({ **default, **args })
    event.save!
    event
  end
end
