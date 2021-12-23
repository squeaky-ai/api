# frozen_string_literal: true

require 'securerandom'

module Helpers
  def graphql_request(query, variables, user)
    context = { current_user: user, request: request }
    SqueakySchema.execute(query, context: context, variables: variables)
  end

  def invite_user(email = nil)
    User.invite!(email: email || 'geeza@gmail.com') { |u| u.skip_invitation = true }
  end

  def create_recording(args = {}, site:, visitor:)
    Fixtures::Recordings.new(site, visitor).create(args)
  end

  def create_recordings(site:, visitor:, count:)
    Fixtures::Recordings.new(site, visitor).sample(count)
  end

  def create_events(recording:, count:)
    Fixtures::Events.new(recording).sample(count)
  end

  def create_visitor(args = {})
    default = { visitor_id: SecureRandom.base36, **args }
    Visitor.create(default)
  end

  def create_page(args = {})
    default = { url: '/', entered_at: 1631629334592, exited_at: 1631629343582, **args }
    Page.create(default)
  end

  def create_sentiment(args = {}, recording:)
    default = { score: 5, comment: nil, **args }
    Sentiment.create(recording: recording, **default)
  end

  def create_nps(args = {}, recording:)
    default = { score: 5, comment: nil, **args }
    Nps.create(recording: recording, **default)
  end
end
