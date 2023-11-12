# frozen_string_literal: true

class SiteService
  def self.find_by_id(current_user, site_id)
    # Raise before we attempt to cache
    raise Exceptions::Unauthorized unless current_user

    # We don't show pending sites to the user in the UI
    teams = { status: Team::ACCEPTED }
    site = current_user.sites.includes(%i[teams users]).find_by(id: site_id, teams:)

    if current_user.superuser? && !site
      # Superusers can access sites if the owner of the site gives
      # them permission via the customer support tab
      site = Site.includes(%i[teams users]).find_by(id: site_id, superuser_access_enabled: true)
    end

    site
  end

  def self.find_by_uuid(current_user, site_uuid, expires_in: 1.minute)
    # This is used externally for the magic erasure and
    # should not raise or it will take out the entire
    # recording. Also this needs to be done outside of
    # the cache so that it does not cache the nil value
    return nil unless current_user

    Rails.cache.fetch("data_cache:SiteService::#{current_user.id}::#{site_uuid}", expires_in:) do
      teams = { status: Team::ACCEPTED }
      current_user.sites.find_by(uuid: site_uuid, teams:)
    end
  end

  def self.exists?(url, expires_in: 5.minutes)
    # This is used mostly for checking the CORS. If it's
    # valid or not the result won't change much within 5
    # minutes. Strip the protocol and www. and whatnot to
    # get a key as clean as possible
    uri = URI(url)
    key = uri.host.downcase.sub('www.', '')
    # Only add the port if it's going to be necessary
    key += ":#{uri.port}" unless [443, 80, nil].include?(uri.port)

    Rails.cache.fetch("data_cache:SiteService::exists::#{key}", expires_in:) do
      # Try both www. and non-www.
      combinations = [
        "#{uri.scheme}://#{key}",
        "#{uri.scheme}://www.#{key}"
      ]
      Site.exists?(url: combinations)
    end
  end

  def self.delete_cache(current_user, site)
    # The find_by_id and find_by_uuid both use this same
    # prefix so clear them both
    Rails.cache.delete("data_cache:SiteService::#{current_user.id}::#{site.id}")
    Rails.cache.delete("data_cache:SiteService::#{current_user.id}::#{site.uuid}")
    # It will also affect the site settings that are used
    # for sessions
    DataCacheService::Sites::Settings.new(site:, user: current_user).delete
  end
end
