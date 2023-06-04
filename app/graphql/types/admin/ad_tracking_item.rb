# frozen_string_literal: true

module Types
  module Admin
    class AdTrackingItem < Types::BaseObject
      graphql_name 'AdminAdTrackingItem'

      field :site_id, ID, null: true
      field :site_name, String, null: true
      field :site_created_at, Types::Common::Dates, null: true
      field :site_verified_at, Types::Common::Dates, null: true
      field :site_plan_name, String, null: true
      field :user_id, ID, null: true
      field :user_name, String, null: true
      field :user_created_at, Types::Common::Dates, null: true
      field :visitor_id, ID, null: false
      field :visitor_visitor_id, String, null: false
      field :utm_content, String, null: false
      field :gad, String, null: true
      field :gclid, String, null: true

      def site_created_at
        DateFormatter.format(date: object[:site_created_at], timezone: context[:timezone])
      end

      def site_verified_at
        DateFormatter.format(date: object[:site_verified_at], timezone: context[:timezone])
      end

      def user_created_at
        DateFormatter.format(date: object[:user_created_at], timezone: context[:timezone])
      end
    end
  end
end
