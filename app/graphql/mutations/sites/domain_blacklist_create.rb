# frozen_string_literal: true

module Mutations
  module Sites
    class DomainBlacklistCreate < SiteMutation
      null false

      graphql_name 'SitesDomainBlacklistCreate'

      argument :site_id, ID, required: true
      argument :type, String, required: true
      argument :value, String, required: true

      type Types::Sites::Site

      def permitted_roles
        [Team::OWNER, Team::ADMIN]
      end

      def resolve(type:, value:, **_rest)
        @site.domain_blacklist << { type: type, value: value }

        if type == 'domain'
          delete_visitors_by_domain(value)
        else
          delete_visitors_by_email(value)
        end

        @site.save

        @site
      end

      private

      def delete_visitors_by_domain(domain)
        visitors = @site.visitors.where("external_attributes->>'email' LIKE ?", "%@#{domain}")

        visitor_ids = visitors.map(&:id)
        recording_ids = visitors.map { |v| v.recordings.map(&:id) }.flatten

        Visitor.destroy(visitor_ids)
        delete_visitors_from_elasticsearch(visitor_ids, recording_ids)
      end

      def delete_visitors_by_email(email)
        visitors = @site.visitors.where("external_attributes->>'email' = ?", email)

        visitor_ids = visitors.map(&:id)
        recording_ids = visitors.map { |v| v.recordings.map(&:id) }.flatten

        Visitor.destroy(visitor_ids)
        delete_visitors_from_elasticsearch(visitor_ids, recording_ids)
      end

      def delete_visitors_from_elasticsearch(visitor_ids, recording_ids)
        return if visitor_ids.empty? && recording_ids.empty?

        SearchClient.bulk(
          body: [
            *visitor_ids.map do |id|
              {
                delete: {
                  _index: Visitor::INDEX,
                  _id: id
                }
              }
            end,
            *recording_ids.map do |id|
              {
                delete: {
                  _index: Recording::INDEX,
                  _id: id
                }
              }
            end
          ]
        )
      end
    end
  end
end
