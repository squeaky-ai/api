# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/free_trial
class FreeTrialPreview < ActionMailer::Preview
  def first
    site = Site.first
    FreeTrialMailer.first(site.id)
  end

  def second
    site = Site.first
    FreeTrialMailer.second(site.id)
  end

  def third
    site = Site.first
    FreeTrialMailer.third(site.id)
  end

  def forth
    site = Site.first
    FreeTrialMailer.forth(site.id)
  end
end
