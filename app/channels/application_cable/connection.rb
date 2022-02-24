# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_visitor

    def connect
      self.current_visitor = find_authorized_visitor
    end

    private

    def find_authorized_visitor
      site = Site.find_by(uuid: visitor[:site_id])

      reject_unauthorized_connection unless site
      reject_unauthorized_connection unless origin_valid?(site)
      reject_unauthorized_connection unless ip_address_valid?(site)

      visitor
    end

    def visitor
      {
        site_id: request.params.fetch(:site_id),
        visitor_id: request.params.fetch(:visitor_id),
        session_id: request.params.fetch(:session_id)
      }
    rescue KeyError
      Rails.logger.warn 'Visitor did not have the correct payload'
      reject_unauthorized_connection
    end

    def origin_valid?(site)
      site.url.sub('www.', '') == request.origin.sub('www.', '')
    end

    def ip_address_valid?(site)
      return true unless site.ip_blacklist.any? { |x| x['value'] == request.ip }

      Rails.logger.info "#{request.ip} was blacklisted by site #{site.id}"
      false
    end
  end
end
