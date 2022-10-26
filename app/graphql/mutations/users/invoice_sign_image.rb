# frozen_string_literal: true

module Mutations
  module Users
    class InvoiceSignImage < UserMutation
      null false

      graphql_name 'UsersInvoiceSignImage'

      argument :filename, String, required: true

      type Types::Users::InvoiceSignImage

      def resolve(filename:)
        return unless @user.partner

        s3_bucket = Aws::S3::Resource.new(region: 'eu-west-1').bucket('invoices.squeaky.ai')

        presigned_url = s3_bucket.presigned_post(
          key: "invoices/#{@user.partner.id}/#{filename}",
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
