# frozen_string_literal: true

class SiteMailer < ApplicationMailer
  def destroyed(email, site)
    @site = site
    mail(to: email, subject: "The team account for #{site.name} has been deleted")
  end
end
