# frozen_string_literal: true

class FeedbackMailer < ApplicationMailer
  def feedback(user, type, subject, message)
    @user = user
    @type = type_name(type)
    @subject = subject
    @message = message
    mail(to: 'hello@squeaky.ai', subject: 'User feedback')
  end

  private

  def type_name(type)
    types = {
      'general' => 'General Enquiry',
      'feature' => 'Feature Request',
      'bug' => 'Bug',
      'complaint' => 'Complaint'
    }
    types[type]
  end
end
