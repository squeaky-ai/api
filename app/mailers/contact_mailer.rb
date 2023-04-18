# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  def contact(details)
    @details = details
    mail(to: 'hello@squeaky.ai', subject: 'Contact form')
  end

  def book_demo(details)
    @details = details
    mail(to: 'hello@squeaky.ai', subject: 'Book demo form')
  end

  def partners(details)
    @details = details
    mail(to: 'hello@squeaky.ai', subject: 'Partners form')
  end

  def startups(details)
    @details = details
    mail(to: 'hello@squeaky.ai', subject: 'Startups form')
  end
end
