# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      origin = request.headers['origin']

      puts '@@@', origin, connection_params
      reject_unauthorized_connection
    end

    def connection_params
      required = %w[site_id session_id viewer_id]
      valid = required.all? { |key| request.params[key] }

      raise 'Missing params' unless valid

      request.params # TODO: makes sure only permited params exist
    end
  end
end
