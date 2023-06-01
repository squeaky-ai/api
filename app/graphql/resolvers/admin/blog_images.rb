# frozen_string_literal: true

module Resolvers
  module Admin
    class BlogImages < Resolvers::Base
      type [String, { null: false }], null: false

      def resolve_with_timings
        client = Aws::S3::Client.new(region: 'eu-west-1')

        items = client
                .list_objects_v2(bucket: 'cdn.squeaky.ai', prefix: 'blog')
                .contents
                .sort_by { |item| -item[:last_modified].to_i }
                .map(&:key)

        items.delete('blog/') # This deletes the folder itself, not anything from S3
        items
      end
    end
  end
end
