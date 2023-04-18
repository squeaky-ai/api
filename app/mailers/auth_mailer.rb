# typed: false
# frozen_string_literal: true

class AuthMailer < Devise::Mailer
  def invitation_instructions(record, token, opts = {})
    @token = token
    @invited_by = record.invited_by
    @site_name = opts[:site_name]
    @new_user = opts[:new_user].nil? ? true : opts[:new_user]
    devise_mail(record, :invitation_instructions, opts)
  end
end
