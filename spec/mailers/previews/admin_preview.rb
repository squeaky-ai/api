# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/admin
class AdminPreview < ActionMailer::Preview
  def site_destroyed
    site = Site.first
    AdminMailer.site_destroyed(site)
  end
end
