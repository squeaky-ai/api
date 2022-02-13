# frozen_string_literal: true

class ReviewEmailsJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    puts '!!'
  end
end
