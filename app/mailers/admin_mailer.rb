# frozen_string_literal: true

class AdminMailer < ApplicationMailer
  def site_destroyed(site)
    @site = site
    mail(to: 'hello@squeaky.ai', subject: 'Site deleted')
  end
end
