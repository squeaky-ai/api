# frozen_string_literal: true

# All of the mailers around teams
class TeamMailer < ApplicationMailer
  # When someone is invited to join a site
  def invite(email, site, user, token)
    @site = site
    @user = user
    @token = token
    mail(to: email, subject: 'You’ve been invited to join Squeaky')
  end

  # Used when someone leaves your team
  def member_left(email, site, user)
    @site = site
    @user = user
    mail(to: email, subject: "A user has left your #{site.name} team.")
  end

  # Used when a user has been removed by another member
  def member_removed(email, site, user)
    @site = site
    @user = user
    mail(to: email, subject: "You have been removed from the #{site.name} team on Squeaky.")
  end

  # When a users' role is upgraded to an admin
  def became_admin(email, site, user)
    @site = site
    @user = user
    mail(to: email, subject: "You’ve been made the Admin of #{site.name}")
  end

  # When ownership is transfered to a user
  def became_owner(email, site, user)
    @site = site
    @user = user
    mail(to: email, subject: "You’ve been made Owner of #{site.name}")
  end
end
