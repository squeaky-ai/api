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

  def require_fixture(relative_path, compress: false) 
    path = "spec/fixtures/#{relative_path}"
    file = File.read(Rails.root.join(path))
    json = JSON.parse(file)

    compress ? compress_events(json) : json
  end

  def compress_events(events_fixture)
    events_fixture.map do |e|
      x = Zlib::Deflate.new.deflate(e, Zlib::FINISH)
      Base64.encode64(x)
    end
  end
end
