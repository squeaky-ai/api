# frozen_string_literal: true

require 'zlib'
require 'base64'
require 'securerandom'

module Helpers
  def graphql_request(query, variables, user)
    context = { current_user: user, request: request }
    SqueakySchema.execute(query, context: context, variables: variables)
  end

  def create_user(args = {})
    default = {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      email: Faker::Internet.email,
      password: Faker::Lorem.sentence
    }
    user = User.create({ **default, **args })
    user.confirm
    user
  end

  def invite_user(email = nil)
    User.invite!(email: email || Faker::Internet.email) { |u| u.skip_invitation = true }
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
    recording = Fixtures::Recordings.new(site).create(args)
    recording.save!
    recording
  end

  def create_recordings(site:, count:)
    recordings = Fixtures::Recordings.new(site).sample(count)
    recordings.each { |r| r.save! }
    recordings
  end

  def create_events(recording:, count:)
    events = Fixtures::Events.new(recording).sample(count)
    events.each { |e| e.save! }
    events
  end

  def create_tag(name = nil, recording:)
    Tag.create(recording: recording, name: name || Faker::Book.title)
  end

  def create_note(args = {}, recording:, user:)
    default = {
      body: Faker::Lorem.sentence,
      timestamp: Faker::Number.number(digits: 5),
      **args
    }
    Note.create(recording: recording, user: user, **default)
  end

  def gzip(payload)
    x = Zlib::Deflate.new.deflate(payload.to_json, Zlib::FINISH)
    Base64.encode64(x)
  end
end
