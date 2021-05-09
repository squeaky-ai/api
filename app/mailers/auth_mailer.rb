# frozen_string_literal: true

# Emails relating to user authentication, there is
# nothing really different between these emails
# besides the wording
class AuthMailer < ApplicationMailer
  # Send when the user is requesting an auth token
  # and they already have an account
  def login(email, token)
    @token = token
    mail(to: email, subject: 'Log in to Squeaky.ai')
  end

  # Send when the user is requesting an auth token
  # and they do not have an account
  def signup(email, token)
    @token = token
    mail(to: email, subject: 'Your sign-up code for Squeaky.ai')
  end
end
