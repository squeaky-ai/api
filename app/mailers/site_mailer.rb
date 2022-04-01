# frozen_string_literal: true

class SiteMailer < ApplicationMailer
  def destroyed(email, site)
    @site = site
    mail(to: email, subject: "The team account for #{site.name} has been deleted")
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
end
