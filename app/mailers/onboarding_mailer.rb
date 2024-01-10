# frozen_string_literal: true

class OnboardingMailer < ApplicationMailer
  def welcome(user_id)
    @user = User.find_by(id: user_id)
    @site = @user&.sites&.first

    return unless should_send?

    mail(to: @user.comms_email, subject: 'A welcome message from the Squeaky founders')
  end

  def getting_started(user_id)
    @user = User.find_by(id: user_id)
    @site = @user&.sites&.first

    return unless should_send?

    mail(to: @user.comms_email, subject: 'Getting started with Squeaky')
  end

  def book_demo(user_id)
    @user = User.find_by(id: user_id)
    @site = @user&.sites&.first

    return unless should_send?

    mail(to: @user.comms_email, subject: 'Book your 1-on-1 introductory demo')
  end

  def install_tracking_code(user_id)
    @user = User.find_by(id: user_id)
    @site = @user&.sites&.first

    return unless should_send?
    # They may also have not added a site yet
    return unless @site
    # If they have already verified their site then there
    # is no need to send this one
    return if @site.verified?

    mail(to: @user.comms_email, subject: 'How to install your Squeaky tracking code')
  end

  def tracking_code_not_installed(user_id)
    @user = User.find_by(id: user_id)
    @site = @user&.sites&.first

    return unless should_send?
    # They've already verified their site so there's no need
    return if @site&.verified?

    mail(to: @user.comms_email, subject: 'How can we make Squeaky work for you?')
  end

  private

  def should_send?
    # The user might have deleted their account while some of
    # these emails were scheduled
    @user&.communication_enabled?(:onboarding_email)
  end
end
