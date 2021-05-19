# frozen_string_literal: true

module Mutations
  # Verify that the auth token the user supplied matches
  # the one we store in redis. If it's valid then we
  # generate a jwt so they use other endpoints. If the
  # user does not exist at this point they will be created
  class AuthVerify < Mutations::BaseMutation
    null false

    argument :email, String, required: true
    argument :token, String, required: true

    field :jwt, String, null: false
    field :user, Types::UserType, null: false
    field :expires_at, String, null: false

    def resolve(email:, token:)
      user = User.find_by(email: email)

      otp = OneTimePassword.new(email)
      token_valid = otp.verify(token)

      raise Errors::AuthInvalid unless token_valid

      otp.delete!
      user ||= User.create(email: email)
      user.update(last_signed_in_at: Time.now)

      exp = 1.month.from_now
      jwt = JsonWebToken.encode(id: user.id, exp: exp)
      { jwt: jwt, user: user, expires_at: exp.iso8601 }
    end
  end
end
