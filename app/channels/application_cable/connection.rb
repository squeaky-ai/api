# frozen_string_literal: true

module ApplicationCable
  # When the user first loads a page on a site, this class
  # in called to identify the user. We validate that the
  # correct params are provided, and that the matching site
  # exists
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      origin = request.headers['origin']
      site = Site.find_by(uuid: connection_params['site_id'])

      reject_unauthorized_connection unless site
      reject_unauthorized_connection unless site.url == origin

      verified_user(site)
    end

    def connection_params
      required = %w[site_id session_id viewer_id]
      valid = required.all? { |key| request.params[key] }

      return request.params if valid

      reject_unauthorized_connection
    end

    def verified_user(site)
      {
        site: site,
        viewer_id: request.params['viewer_id'],
        session_id: request.params['session_id']
      }
    end
  end
end
