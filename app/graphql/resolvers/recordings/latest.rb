# frozen_string_literal: true

module Resolvers
  module Recordings
    class Latest < Resolvers::Base
      type Types::Recordings::Recording, null: true

      def resolve
        Recording
          .eager_load(:visitor, :pages)
          .where(site_id: object.id, status: Recording::ACTIVE)
          .order('disconnected_at DESC')
          .first
      end
    end
  end
end
