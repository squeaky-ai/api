# frozen_string_literal: true

class NewFeedbackJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    feedback_data.compact.each do |data|
      # Each team member should receive this email
      data[:site].team.each do |team|
        SiteMailer.new_feedback(data, team.user).deliver_now
      end
    end
  end

  private

  def feedback_data
    now = Time.now

    Site.find_each.map do |site|
      nps = site.nps.where('nps.created_at > ?', now - 1.hour).to_a
      sentiment = site.sentiments.where('sentiments.created_at > ?', now - 1.hour).to_a

      next nil if nps.empty? && sentiment.empty?

      { site:, nps:, sentiment: }
    end
  end
end
