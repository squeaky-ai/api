# frozen_string_literal: true

class DataExportJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(data_export_id)
    @data_export = DataExport.find(data_export_id)

    store_data_export!

    data_export.update(exported_at: Time.current.to_i * 1000)
  end

  private

  attr_reader :data_export

  def store_data_export!
    DataExportService.create(data_export:, body: create_csv)
  end

  def create_csv
    case data_export.export_type
    when DataExport::VISITORS
      create_visitors_csv
    when DataExport::RECORDINGS
      create_recordings_csv
    else
      raise StandardError, "Don't know how to handle #{data_export.type} for data export"
    end
  end

  def create_recordings_csv
    records = ::Recording
      .includes(:nps, :sentiment)
      .joins(:pages, :visitor)
      .preload(:pages, :visitor)
      .where(
        'recordings.site_id = ? AND to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ?',
        data_export.site_id,
        data_export.start_date,
        data_export.end_date
      )

    return '' if records.empty?

    serialized_records = records.map { |r| DataExportSerializers::RecordingSerializer.new(r).serialize }

    generate_csv(serialized_records)
  end

  def create_visitors_csv
    records = ::Visitor
      .left_outer_joins(:recordings)
      .where(
        'visitors.site_id = ? AND visitors.created_at BETWEEN ? AND ?',
        data_export.site_id,
        data_export.start_date,
        data_export.end_date
      )

    return '' if records.empty?

    serialized_records = records.map { |r| DataExportSerializers::VisitorSerializer.new(r).serialize }

    generate_csv(serialized_records)
  end

  def generate_csv(serialized_records)
    CSV.generate do |csv|
      csv << serialized_records.first.keys
      serialized_records.each { |r| csv << r.values }
    end
  end
end
