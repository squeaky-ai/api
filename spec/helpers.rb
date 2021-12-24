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
end
