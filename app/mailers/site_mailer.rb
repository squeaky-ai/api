# frozen_string_literal: true

class SiteMailer < ApplicationMailer
  def destroyed(team, site)
    @site = site
    @team = team
    subject = team.owner? ? 'Site deletion follow-up' : "The team account for #{site.name} has been deleted"

    mail(to: team.user.email, subject:)
  end

  def weekly_review(site, data, user)
    @site = site
    @data = data
    @unsubscribable = true

    return unless user.communication_enabled?(:weekly_review_email)

    mail(to: user.email, subject: 'Your Week In Review')
  end

  def plan_exceeded(site, data, user)
    @site = site
    @user = user
    @data = data

    mail(to: user.email, subject: "You've exceeded your monthly visit limit on #{site.name}")
  end

  def plan_nearing_limit(site, user)
    @site = site
    @user = user

    mail(to: user.email, subject: "You'll exceed your monthly visit limit soon for #{site.name}")
  end

  def new_feedback(data, user)
    @site = data[:site]
    @nps = data[:nps]
    @sentiment = data[:sentiment]

    return unless user.communication_enabled?(:feedback_email)

    mail(to: user.email, subject: "You've got new feedback from your visitors")
  end

  def tracking_code_instructions(site, first_name, email)
    @site = site
    @owner = site.owner.user
    @first_name = first_name
    @tracking_code = site.tracking_code

    mail(to: email, subject: "Your colleague #{@owner.full_name} needs your help")
  end
end
