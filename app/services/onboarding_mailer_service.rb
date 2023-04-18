# frozen_string_literal: true

class OnboardingMailerService
  class << self
    def enqueue(user)
      new(user).enqueue_all
    end
  end

  def initialize(user)
    @user = user
    @site = user.sites.first
    @team = user.teams.find { |t| t.site_id = @site.id }
  end

  def enqueue_all
    enqueue_welcome
    enqueue_getting_started
    enqueue_book_demo
    enqueue_install_tracking_code
    enqueue_tracking_code_not_installed
  end

  private

  attr_reader :site, :user, :team

  def enqueue_welcome
    # Recipients:
    # Owners
    #
    # When to send:
    # Owner: 5 minutes

    return unless owner?

    OnboardingMailer.welcome(user.id).deliver_later(wait: 5.minutes)
  end

  def enqueue_getting_started
    # Recipients:
    # Owners, Admins, User
    #
    # When to send:
    # Owner: 24 hours
    # Admin: Immediately,
    # User: Immediately
    # Readonly: Immediately

    waits = {
      Team::OWNER => 24.hours,
      Team::ADMIN => 0,
      Team::MEMBER => 0,
      Team::READ_ONLY => 0
    }

    role = team&.role || Team::OWNER
    OnboardingMailer.getting_started(user.id).deliver_later(wait: waits[role])
  end

  def enqueue_book_demo
    # Recipients
    # Owners, Admins
    #
    # When to send:
    # Owner: 48 hours
    # Admin: 48 hours

    return unless owner? || admin?

    OnboardingMailer.book_demo(user.id).deliver_later(wait: 48.hours)
  end

  def enqueue_install_tracking_code
    # Recipients:
    # Owners, Admins
    #
    # When to send:
    # Owner: 96 hours
    # Admin: 96 hours
    #
    # Conditions
    # Site is not verified (has to be checked in the mailer as the state of the world can have changed)

    return unless owner? || admin?

    OnboardingMailer.install_tracking_code(user.id).deliver_later(wait: 96.hours)
  end

  def enqueue_tracking_code_not_installed
    # Recipients:
    # Owners, Admins
    #
    # When to send:
    # Owner: 240 hours
    # Admin: 240 hours
    #
    # Conditions
    # Site is not verified (has to be checked in the mailer as the state of the world can have changed)

    return unless owner? || admin?

    OnboardingMailer.tracking_code_not_installed(user.id).deliver_later(wait: 240.hours)
  end

  def owner?
    # If a user has just created an account, then they will not have a site
    # at all so we make the assumption that they will create a site soon
    # (and therefor be an owner). This will not work if someone creates a
    # site and then gets invited, but that is an edge case
    return true unless site

    user.owner_for?(site)
  end

  def admin?
    # Same as above, just assume they are the owner
    return false unless site

    user.admin_for?(site)
  end
end
