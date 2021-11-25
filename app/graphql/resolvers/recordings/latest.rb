# frozen_string_literal: true

module Resolvers
  module Recordings
    class RecordingLatestExtension < Resolvers::Base
      def resolve
        Recording
          .eager_load(:visitor, :pages)
          .where(site_id: object.id, deleted: false)
          .order('disconnected_at DESC')
          .first
      end
    end
  end
end
