# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :authenticate_user!

  def show
    invoice = current_user.partner.invoices.find_by(id: params[:id])
    return not_found unless invoice

    fetch_file(invoice)
  end

  private

  def fetch_file(invoice)
    client = Aws::S3::Client.new

    object = client.get_object(
      key: "#{invoice.partner_id}/#{invoice.filename}",
      bucket: 'invoices.squeaky.ai'
    )

    send_data(object.body.read, filename: invoice.filename, type: object.content_type)
  rescue Aws::S3::Errors::NoSuchKey => e
    Rails.logger.error "Key did not exist: #{invoice.partner_id}/#{invoice.filename} - #{e}"
    not_found
  end
end
