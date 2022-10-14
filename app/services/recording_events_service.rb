# frozen_string_literal: true

class RecordingEventsService
  class << self
    def list(recording:)
      new(recording).list_keys
    end

    def get(recording:, filename:)
      new(recording).get_object(filename)
    end

    def create(recording:, body:, filename:)
      new(recording).create_object(body, filename)
    end

    def delete(recording:)
      new(recording).delete_objects
    end
  end

  def initialize(recording)
    @client = Aws::S3::Client.new
    @recording = recording
  end

  attr_reader :client, :recording

  def list_keys
    objects = client.list_objects_v2(prefix:, bucket:)
    objects.contents.map { |c| c[:key].split('/').last }.filter { |c| c.end_with?('.json') }
  end

  def get_object(filename)
    object = client.get_object(key: "#{prefix}/#{filename}", bucket:)
    Oj.load(object.body.read)
  rescue Aws::S3::Errors::NoSuchKey => e
    Rails.logger.error "Key did not exist: #{prefix}/#{filename} - #{e}"
    nil
  end

  def delete_objects
    objects = list_keys
    return if objects.empty?

    payload = { objects: objects.map { |f| { key: "#{prefix}/#{f}" } } }
    client.delete_objects(bucket:, delete: payload)

    nil
  end

  def create_object(body, filename)
    client.put_object(
      body:,
      bucket:,
      key: "#{prefix}/#{filename}"
    )

    filename
  end

  private

  def bucket
    'events.squeaky.ai'
  end

  def prefix
    "#{recording.site.uuid}/#{recording.visitor.visitor_id}/#{recording.session_id}"
  end
end
