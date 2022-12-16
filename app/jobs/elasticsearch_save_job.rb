# frozen_string_literal: true

class ElasticsearchSaveJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(id, type)
    case type
    when 'visitor'
      save_visitor(id)
    when 'recording'
      save_recording(id)
    else
      Rails.logger.warn("Not sure how to save ElasticSearch record with type #{type}")
    end
  end

  private

  def save_visitor(id)
    visitor = Visitor.find(id)
    serialized_visitor = VisitorSerializer.new(visitor).serialize
    puts '@@', serialized_visitor
  end

  def save_recording(id)
    recording = Recording.find(id)
    serialized_recording = RecordingSerializer.new(recording).serialize
    puts '@@', serialized_recording
  end
end
