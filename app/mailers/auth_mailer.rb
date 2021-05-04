# frozen_string_literal: true

class AuthMailer < ApplicationMailer
  def login(email, token)
    @token = token
    mail(to: email, subject: 'Log in to Squeaky.ai')
  end

  def signup(email, token)
    @token = token
    mail(to: email, subject: 'Your sign-up code for Squeaky.ai')
  end
end
