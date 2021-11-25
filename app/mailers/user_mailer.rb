# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def updated(user)
    @user = user
    mail(to: user.email, subject: 'Your account details have been updated.')
  end

  def destroyed(email)
    mail(to: email, subject: 'Account Deletion Confirmed')
  end
end
