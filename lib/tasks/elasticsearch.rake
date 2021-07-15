# frozen_string_literal: true

namespace :elasticsearch do
  task create_recordings_index: :environment do
    Rails.logger.info('Creating recordings index')

    es = SearchClient
    index = Recording::INDEX

    es.indices.create(index: index) unless es.indices.exists(index: index)
  end

  task delete_recordings_index: :environment do
    Rails.logger.info('Deleting recordings index')

    es = SearchClient
    index = Recording::INDEX

    es.indices.delete(index: index) if es.indices.exists(index: index)
  end

  task import_recordings_data: :environment do
    Rails.logger.info('Importing recordings data')

    records = Recording.all
    es = SearchClient
    index = Recording::INDEX

    Rails.logger.info("Found #{records.size} recordings")

    records.each_slice(250).with_index do |slice, i|
      Rails.logger.info("Bulk inserting batch #{i}")

      es.bulk(
        body: slice.map do |record|
          {
            index: {
              _index: index,
              _id: "#{record.site_id}_#{record.viewer_id}_#{record.session_id}",
              data: record.to_h
            }
          }
        end
      )
    end
  end
end
