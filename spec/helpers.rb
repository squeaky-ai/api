# frozen_string_literal: true

module Helpers
  def graphql_request(query, variables, user)
    context = { current_user: user, request:, timezone: 'UTC' }
    SqueakySchema.execute(query, context:, variables:)
  end

  def invite_user(email = nil)
    User.invite!(email: email || 'geeza@gmail.com') { |u| u.skip_invitation = true }
  end

  def require_fixture(relative_path, compress: false, symbolize_names: false)
    path = "spec/fixtures/#{relative_path}"
    file = Rails.root.join(path).read
    json = JSON.parse(file, symbolize_names:)

    compress ? compress_events(json) : json
  end

  def compress_events(events_fixture)
    events_fixture.map do |e|
      x = Zlib::Deflate.new.deflate(e, Zlib::FINISH)
      Base64.encode64(x)
    end
  end
end
