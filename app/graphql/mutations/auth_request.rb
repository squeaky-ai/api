# frozen_string_literal: true

require 'date'

module Mutations
  # Generate an auth token and send it to the users email
  # address so that they can verify it against the one that
  # we store. The client must provide the auth_type as the
  # behaviour is different between the two
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
        AuthMailer.login(email, token).deliver_now
      when 'SIGNUP'
        AuthMailer.signup(email, token).deliver_now
      end
    end

    def ready?(_args)
      # The backoff will be cleared when the user gets the
      # token correct, or they will need to wait for the
      # key to expire. Given there's no right/wrong to this
      # path, we incr! every single time
      Backoff.new(context[:request].remote_ip).incr!
      true
    end
  end
end
