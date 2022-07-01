# frozen_string_literal: true

class SiteService
  def self.find_by_id(current_user, site_id, expires_in: 1.minute)
    # Raise before we attempt to cache
    raise Errors::Unauthorized unless current_user

    Rails.cache.fetch("data_cache:SiteService::#{current_user.id}::#{site_id}", expires_in:) do
      # Superusers can access sites if the owner of the site gives
      # them permission via the customer support tab
      if current_user.superuser?
        site = Site.includes(%i[teams users]).find_by(id: site_id)
        site if site&.superuser_access_enabled?
      else
        # We don't show pending sites to the user in the UI
        team = { status: Team::ACCEPTED }
        current_user.sites.includes(%i[teams users]).find_by(id: site_id, team:)
      end
    end
  end

  def self.find_by_uuid(current_user, site_uuid, expires_in: 1.minute)
    # This is used externally for the magic erasure and
    # should not raise or it will take out the entire
    # recording. Also this needs to be done outside of
    # the cache so that it does not cache the nil value
    return nil unless current_user

    Rails.cache.fetch("data_cache:SiteService::#{current_user.id}::#{site_uuid}", expires_in:) do
      team = { status: Team::ACCEPTED }
      current_user.sites.find_by(uuid: site_uuid, team:)
    end
  end
end
