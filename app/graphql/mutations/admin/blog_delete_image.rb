# frozen_string_literal: true

module Mutations
  module Admin
    class BlogDeleteImage < BaseMutation
      null false

      graphql_name 'AdminBlogDeleteImage'

      argument :key, String, required: true

      type Types::Common::GenericSuccess

      def resolve(key:)
        raise Errors::Unauthorized unless context[:current_user]&.superuser?

        client = Aws::S3::Client.new(region: 'eu-west-1')

        client.delete_object(bucket: 'cdn.squeaky.ai', key:)

        { message: 'Image deleted' }
      end
    end
  end
end
