# frozen_string_literal: true

namespace :elasticsearch do
  task create_recordings_index: :environment do
    Rails.logger.info('Creating recordings index')

    if SearchClient.indices.exists(index: Recording::INDEX)
      Rails.logger.warn('Recordings index already exists')
    else
      SearchClient.indices.create(index: Recording::INDEX)
    end
  end

  task create_visitors_index: :environment do
    Rails.logger.info('Creating visitors index')

    if SearchClient.indices.exists(index: Visitor::INDEX)
      Rails.logger.warn('Visitors index already exists')
    else
      SearchClient.indices.create(index: Visitor::INDEX)
    end
  end

  task delete_recordings_index: :environment do
    Rails.logger.info('Deleting recordings index')

    if SearchClient.indices.exists(index: Recording::INDEX)
      SearchClient.indices.delete(index: Recording::INDEX)
    else
      Rails.logger.warn('Recordings index does not exists')
    end
  end

  task delete_visitors_index: :environment do
    Rails.logger.info('Deleting visitors index')

    if SearchClient.indices.exists(index: Visitor::INDEX)
      SearchClient.indices.delete(index: Visitor::INDEX)
    else
      Rails.logger.warn('Visitors index does not exists')
    end
  end

  task import_recordings: :environment do
    Rails.logger.info('Importing recordings')

    Recording.all.each_slice(100).with_index do |slice, i|
      Rails.logger.info("Bulk inserting batch #{i} of recordings")

      SearchClient.bulk(
        body: slice.map do |recording|
          {
            index: {
              _index: Recording::INDEX,
              _id: recording.id.to_s,
              data: recording.to_h
            }
          }
        end
      )
    end
  end

  task import_visitors: :environment do
    Rails.logger.info('Importing visitors')

    Visitor.all.each_slice(100).with_index do |slice, i|
      Rails.logger.info("Bulk inserting batch #{i} of visitors")

      SearchClient.bulk(
        body: slice.map do |visitor|
          {
            index: {
              _index: Visitor::INDEX,
              _id: visitor.id.to_s,
              data: visitor.to_h
            }
          }
        end
      )
    end
  end
end
