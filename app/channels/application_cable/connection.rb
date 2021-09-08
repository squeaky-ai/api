# frozen_string_literal: true

module ApplicationCable
  # Entry point for the cable that stores the visitor
  # details in the scope
  class Connection < ActionCable::Connection::Base
    identified_by :current_visitor

    def connect
      self.current_visitor = find_authorized_visitor
    end

    private

    def find_authorized_visitor
      site = Site.find_by(uuid: visitor[:site_id])

      reject_unauthorized_connection unless site
      reject_unauthorized_connection unless site.url.sub('www.', '') == request.origin

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
  end
end
