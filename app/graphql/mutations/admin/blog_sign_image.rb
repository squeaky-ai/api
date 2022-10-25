# frozen_string_literal: true

module Mutations
  module Admin
    class BlogSignImage < AdminMutation
      null false

      graphql_name 'AdminBlogSignImage'

      argument :filename, String, required: true

      type Types::Admin::BlogSignImage

      def resolve(filename:)
        s3_bucket = Aws::S3::Resource.new(region: 'eu-west-1').bucket('cdn.squeaky.ai')

        presigned_url = s3_bucket.presigned_post(
          key: "blog/covers/#{filename}",
          success_action_status: '201',
          signature_expiration: (Time.now.utc + 15.minutes)
        )

        {
          url: presigned_url.url,
          fields: presigned_url.fields.to_json
        }
      end
    end
  end
end
