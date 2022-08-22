# frozen_string_literal: true

namespace :backfill do # rubocop:disable Metrics/BlockLength
  task visitor_site_ids: :environment do
    sql = <<-SQL
      SELECT site_id, visitor_id
      FROM recordings
      GROUP BY visitor_id, site_id;
    SQL

    visitor_site_ids = ActiveRecord::Base.connection.exec_query(sql)

    visitor_site_ids.each_slice(1000).with_index do |slice, index|
      Rails.logger.info "Backfilling batch #{index}"

      ActiveRecord::Base.transaction do
        slice.each do |s|
          Visitor.where(id: s['visitor_id']).update(site_id: s['site_id'])
        end
      end
    end
  end

  task page_site_ids: :environment do
    sql = <<-SQL
      SELECT id, site_id
      FROM recordings
      GROUP BY id
    SQL

    recording_site_ids = ActiveRecord::Base.connection.exec_query(sql)

    recording_site_ids.each_slice(1000).with_index do |slice, index|
      Rails.logger.info "Backfilling batch #{index}"

      ActiveRecord::Base.transaction do
        slice.each do |s|
          Page.where(recording_id: s['id']).update(site_id: s['site_id'])
        end
      end
    end
  end
end
