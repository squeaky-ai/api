# frozen_string_literal: true

# All of the mailers for the site that is
# not related to teams
class SiteMailer < ApplicationMailer
  def destroyed(email, site)
    @site = site
    mail(to: email, subject: "The team account for #{site.name} has been deleted")
  end
end
