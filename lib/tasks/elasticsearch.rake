# frozen_string_literal: true

namespace :elasticsearch do
  desc 'Create the recordings index'

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

    records = []
    es = SearchClient
    index = Recording::INDEX

    Recording.scan.each { |r| records << r }

    records.each_slice(250) do |slice|
      es.bulk(
        body: slice.map do |record|
          {
            index: { _index: index, data: record.serialize }
          }
        end
      )
    end
  end
end
