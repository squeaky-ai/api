# frozen_string_literal: true

module Resolvers
  module Admin
    class ActiveMonthlyUsers < Resolvers::Base
      type Integer, null: false

      def resolve
        now = Time.current
        now -= 30.days
        ::User.where('last_activity_at > ?', now).count
      end
    end
  end
end
