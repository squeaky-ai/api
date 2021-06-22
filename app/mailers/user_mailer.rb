# frozen_string_literal: true

# Mailers for users that are not covered by Devise
class UserMailer < ApplicationMailer
  # When the user changes some account settings
  def updated(user)
    @user = user
    mail(to: user.email, subject: 'Your account details have been updated.')
  end
end
