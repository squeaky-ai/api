# frozen_string_literal: true

class FreeTrialMailer < ApplicationMailer
  def first(site_id)
    @site = Site.find_by(id: site_id)
    @user = @site&.owner&.user
    @unsubscribable = true

    return unless should_send?

    mail(to: @user.email, subject: 'Your free trial of Squeaky\'s paid features has started...')
  end

  def second(site_id)
    @site = Site.find_by(id: site_id)
    @user = @site&.owner&.user
    @unsubscribable = true

    return unless should_send?

    mail(to: @user.email, subject: 'You\'re halfway through your advanced features trial - are you making the most of it?')
  end

  def third(site_id)
    @site = Site.find_by(id: site_id)
    @user = @site&.owner&.user
    @unsubscribable = true

    return unless should_send?

    mail(to: @user.email, subject: 'Only 2 days left - maximize your Squeaky experience')
  end

  def forth(site_id)
    @site = Site.find_by(id: site_id)
    @user = @site&.owner&.user
    @unsubscribable = true

    return unless should_send?

    mail(to: @user.email, subject: 'Your trial of Squeaky\'s premium features has ended...')
  end

  private

  def should_send?
    return false unless @site
    return false unless @site.plan.free?

    @user.communication_enabled?(:onboarding_email)
  end
end
