# typed: false
# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/onboarding
class OnboardingPreview < ActionMailer::Preview
  def welcome
    user = User.first
    OnboardingMailer.welcome(user.id)
  end

  def getting_started
    user = User.first
    OnboardingMailer.getting_started(user.id)
  end

  def book_demo
    user = User.first
    OnboardingMailer.book_demo(user.id)
  end

  def install_tracking_code
    user = User.first
    OnboardingMailer.install_tracking_code(user.id)
  end

  def tracking_code_not_installed
    user = User.first
    OnboardingMailer.tracking_code_not_installed(user.id)
  end
end
