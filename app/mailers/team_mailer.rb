# frozen_string_literal: true

class TeamMailer < ApplicationMailer
  def invite(email, site, inviter, token)
    @site = site
    @inviter = inviter
    @token = token
    # TODO: Configure the url with the token in it
    mail(to: email, subject: 'You’ve been invited to join Squeaky')
  end

  # Used when someone leaves your team
  def member_left(email, site, leaver)
    @site = site
    @leaver = leaver
    mail(to: email, subject: "A user has left your #{site.name} team.")
  end

  # Used when a user has been removed by another member
  def member_removed(email, site, user)
    @site = site
    @user = user
    mail(to: email, subject: "You have been removed from the #{site.name} team on Squeaky.")
  end
end
