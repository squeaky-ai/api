# frozen_string_literal: true

class RecordingMailerService
  class << self
    def enqueue(site)
      new(site).enqueue_all
    end
  end

  def initialize(site)
    @site = site
  end

  def enqueue_all
    enqueue_first_recording
    enqueue_first_recording_followup
  end

  private

  attr_reader :site

  def enqueue_first_recording
    # Recipients:
    # Owners, Admins
    #
    # When to send:
    # Immediately

    RecordingMailer.first_recording(site.id).deliver_later(wait: 0)
  end

  def enqueue_first_recording_followup
    # Recipients:
    # Owners, Admins
    #
    # When to send:
    # 24 hours

    RecordingMailer.first_recording_followup(site.id).deliver_later(wait: 24.hours)
  end
end
