# frozen_string_literal: true

namespace :elasticsearch do
  desc 'Create the recordings index'

  task create_recordings_index: :environment do
    Rails.logger.info('Creating recordings index')

    es = SearchClient
    es.indices.create(index: 'recordings') unless es.indices.exists(index: 'recordings')
  end

  task delete_recordings_index: :environment do
    Rails.logger.info('Deleting recordings index')

    es = SearchClient
    es.indices.delete(index: 'recordings') if es.indices.exists(index: 'recordings')
  end

  task import_recordings_data: :environment do
    Rails.logger.info('Importing recordings data')

    records = []
    es = SearchClient

    Recording.scan.each { |r| records << r }

    records.each_slice(250) do |slice|
      es.bulk(
        body: slice.map do |record|
          {
            index: { _index: 'recordings', data: record.serialize }
          }
        end
      )
    end
  end
end
