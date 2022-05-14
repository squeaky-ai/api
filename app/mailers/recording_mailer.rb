# frozen_string_literal: true

class RecordingMailer < ApplicationMailer
  def first_recording(site_id)
    @site = Site.find_by(id: site_id)

    return unless @site

    emails = owner_and_admin_emails

    mail(to: emails, subject: 'Your first Squeaky recording is in! 👀') unless emails.empty?
  end

  def first_recording_followup(site_id)
    @site = Site.find_by(id: site_id)

    return unless @site

    emails = owner_and_admin_emails

    mail(to: emails, subject: 'Capture only the right data') unless emails.empty?
  end

  private

  def owner_and_admin_emails
    members = @site.team.filter do |team|
      [Team::OWNER, Team::ADMIN].include?(team.role) && team.user.communication_enabled?(:onboarding_email)
    end

    members.map { |m| m.user.email }
  end
end