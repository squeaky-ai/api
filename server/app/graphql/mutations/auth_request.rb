# frozen_string_literal: true

require 'date'

module Mutations
  class AuthRequest < Mutations::BaseMutation
    null false

    argument :email, String, required: true
    argument :auth_type, Types::AuthType, required: true

    field :email_sent_at, String, null: false

    def resolve(email:, auth_type:)
      user = User.find_by(email: email)

      raise Errors::UserAccountExists if user && auth_type == 'SIGNUP'

      raise Errors::UserAccountNotExists if !user && auth_type == 'LOGIN'

      one_time_password = OneTimePassword.new(email).create!
      send_mail!(auth_type, email, one_time_password)

      { email_sent_at: DateTime.now.iso8601 }
    end

    private

    def send_mail!(auth_type, email, token)
      case auth_type
      when 'LOGIN'
        AuthTokenMailer.login(email, token).deliver_now
      when 'SIGNUP'
        AuthTokenMailer.signup(email, token).deliver_now
      end
    end
  end
end
