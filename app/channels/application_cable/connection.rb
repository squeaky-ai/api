# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_visitor

    def connect
      self.current_visitor = find_authorized_visitor
    end

    private

    def find_authorized_visitor
      site = Site.find_by(uuid: site_uuid)

      reject_unauthorized_connection unless site
      reject_unauthorized_connection unless origin_valid?(site)
      reject_unauthorized_connection unless ip_address_valid?(site)
      reject_unauthorized_connection unless allow_connection?(site)

      "#{site_uuid}::#{visitor_id}::#{session_id}"
    rescue KeyError
      Rails.logger.warn 'Visitor did not have the correct payload'
      reject_unauthorized_connection
    end

    def origin_valid?(site)
      return true if site.url.sub('www.', '') == request.origin.sub('www.', '')

      Rails.logger.info "#{site.name} - origins did not match"
      false
    end

    def ip_address_valid?(site)
      return true unless site.ip_blacklist.any? { |x| x['value'] == request.ip }

      Rails.logger.info "#{site.name} - #{request.ip} was blacklisted"
      false
    end

    def allow_connection?(site)
      return true if site.ingest_enabled && !site.plan.exceeded? && !site.plan.invalid?

      Rails.logger.info "#{site.name} - not allowed to connect"
      false
    end

    def site_uuid
      request.params.fetch(:site_id)
    end

    def visitor_id
      request.params.fetch(:visitor_id)
    end

    def session_id
      request.params.fetch(:session_id)
    end
  end
end
