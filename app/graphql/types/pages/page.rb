# typed: false
# frozen_string_literal: true

module Types
  module Pages
    class Page < Types::BaseObject
      graphql_name 'Page'

      field :id, ID, null: false
      field :url, String, null: false
      field :entered_at, Types::Common::Dates, null: false
      field :exited_at, Types::Common::Dates, null: false

      def entered_at
        DateFormatter.format(date: object.entered_at, timezone: context[:timezone])
      end

      def exited_at
        DateFormatter.format(date: object.exited_at, timezone: context[:timezone])
      end
    end
  end
end
