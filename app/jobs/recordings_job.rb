# frozen_string_literal: true

# Pick up recordings from the recordings queue
# and index them into elasticsearch
class RecordingsJob < ApplicationJob
  queue_as :recordings

  self.queue_adapter = :amazon_sqs

  def perform(args)
    message = JSON.parse(args)
    recording = Recording.find(site_id: message['site_id'], session_id: message['session_id'])

    unless recording
      Rails.logger.warn 'No recording found in DynamoDB'
      return
    end

    Rails.logger.info 'Indexing recording into ElasticSearch'

    SearchClient.update(
      index: Recording::INDEX,
      id: "#{recording.site_id}_#{recording.viewer_id}_#{recording.session_id}",
      body: {
        doc: recording.serialize,
        doc_as_upsert: true
      }
    )
  end
end
