# frozen_string_literal: true

module Mutations
  class AuthVerify < Mutations::BaseMutation
    null false

    argument :email, String, required: true
    argument :token, String, required: true

    field :jwt, String, null: true

    def resolve(email:, token:)
      user = User.find_by(email: email)

      otp = OneTimePassword.new(email)
      token_valid = otp.verify(token)

      raise Errors::AuthInvalid unless token_valid

      otp.delete!
      user ||= User.create(email: email)
      user.update(last_signed_in_at: Time.now)

      jwt = JsonWebToken.encode(id: user.id)
      { jwt: jwt }
    end
  end
end