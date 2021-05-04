# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'Squeaky.ai <hello@squeaky.ai>'
  layout 'mailer'
end
