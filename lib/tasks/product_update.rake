# frozen_string_literal: true

namespace :product_update do
  task send: :environment do
    site_ids = Plan.where(plan_id: '05bdce28-3ac8-4c40-bd5a-48c039bd3c7f').map(&:site_id)

    owners = []

    Site.where(id: site_ids).find_each do |s|
      owner_user = s.owner.user

      next unless s.team.any? do |t|
        if t.user.last_activity_at
          t.user.last_activity_at > 6.months.ago
        else
          false
        end
      end

      owners.push(owner_user)
    end

    owners.uniq(&:email).each do |u|
      ProductUpdatesMailer.free_plan_changes_2023(u).deliver_later
    end
  end
end
