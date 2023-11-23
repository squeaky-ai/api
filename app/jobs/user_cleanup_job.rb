# frozen_string_literal: true

class UserCleanupJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    now = Time.current

    count = 0

    User.find_each do |user|
      # Delete users who:
      # - Created their account on their own
      # - Never confirmed their email
      # - Are older than 48 hours
      next if user.created_by_invite?
      next if user.confirmed?
      next if user.created_at > now - 48.hours

      logger.info("Destroying user #{user.id} as they did not confirm after 48 hours")
      Stats.count('destroyed_unconfirmed_user')

      count += 1

      user.destroy
    end

    logger.info("Destroyed #{count} unconfirmed users")

    nil
  end
end
