# frozen_string_literal: true

namespace :product_update do
  task send: :environment do
    site_ids = Plan.where(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f').map(&:site_id)

    owners = []

    Site.where(id: site_ids).find_each do |s|
      owner_user = s.owner.user

      next unless s.team.any? { |t| t.user.last_activity_at > 6.months.ago }

      owners.push(owner_user)
    end

    unique_owners = owners.uniq(&:email)

    puts "Would send emails to #{unique_owners.size} owners"
  end
end
