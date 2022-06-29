# frozen_string_literal: true

module Resolvers
  module Admin
    class BlogImages < Resolvers::Base
      type [String, { null: true }], null: false

      def resolve_with_timings
        client = Aws::S3::Client.new(region: 'eu-west-1')

        items = client.list_objects_v2(bucket: 'cdn.squeaky.ai', prefix: 'blog/').contents.map(&:key)
        items.delete('blog/')
        items
      end
    end
  end
end
