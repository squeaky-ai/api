# frozen_string_literal: true

# Preview all emails at http://localhost:4000/rails/mailers/recording
class RecordingPreview < ActionMailer::Preview
  def first_recording
    site = Site.first
    RecordingMailer.first_recording(site.id)
  end

  def first_recording_followup
    site = Site.first
    RecordingMailer.first_recording_followup(site.id)
  end
end
