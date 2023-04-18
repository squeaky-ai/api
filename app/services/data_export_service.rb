# typed: false
# frozen_string_literal: true

class DataExportService
  class << self
    def get(data_export:)
      new(data_export).fetch_object
    end

    def create(data_export:, body:)
      new(data_export).create_object(body)
    end

    def delete(data_export:)
      new(data_export).delete_object
    end
  end

  def initialize(data_export)
    @client = Aws::S3::Client.new
    @data_export = data_export
  end

  attr_reader :client, :data_export

  def delete_object
    client.delete_object(bucket:, key:)
    nil
  end

  def create_object(body)
    client.put_object(body:, bucket:, key:)
    nil
  end

  def fetch_object
    object = client.get_object(key:, bucket:)
    object.body.read
  rescue Aws::S3::Errors::NoSuchKey => e
    Rails.logger.error "Key did not exist: #{key} - #{e}"
    nil
  end

  private

  def bucket
    'misc.squeaky.ai'
  end

  def key
    "data_export/#{data_export.site.uuid}/#{data_export.id}"
  end
end
