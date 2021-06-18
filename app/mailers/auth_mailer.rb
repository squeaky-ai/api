# frozen_string_literal: true

# Override the devise_invitable mailer to include the exta
# data we need for our custom template. All other devise
# emails should fall through
class AuthMailer < Devise::Mailer
  def invitation_instructions(record, token, opts = {})
    @token = token
    @invited_by = record.invited_by
    @site_name = opts[:site_name]
    @new_user = opts[:new_user] || true
    devise_mail(record, :invitation_instructions, opts)
  end
end
