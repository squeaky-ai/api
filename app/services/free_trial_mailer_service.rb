# frozen_string_literal: true

class FreeTrialMailerService
  class << self
    def enqueue(site)
      new(site).enqueue_all
    end
  end

  def initialize(site)
    @site = site
  end

  def enqueue_all
    enqueue_first
    enqueue_second
    enqueue_third
    enqueue_forth
  end

  private

  attr_reader :site

  def enqueue_first
    # Recipients:
    # Owners
    #
    # When to send:
    # Owner: 24 hours

    FreeTrialMailer.first(site.id).deliver_later(wait: 24.hours)
  end

  def enqueue_second
    # Recipients:
    # Owners
    #
    # When to send:
    # Owner: 168 hours (7 days)

    FreeTrialMailer.second(site.id).deliver_later(wait: 168.hours)
  end

  def enqueue_third
    # Recipients:
    # Owners
    #
    # When to send:
    # Owner: 288 hours (12 days)

    FreeTrialMailer.third(site.id).deliver_later(wait: 288.hours)
  end

  def enqueue_forth
    # Recipients:
    # Owners
    #
    # When to send:
    # Owner: 336 hours (14 days)

    FreeTrialMailer.forth(site.id).deliver_later(wait: 336.hours)
  end
end
