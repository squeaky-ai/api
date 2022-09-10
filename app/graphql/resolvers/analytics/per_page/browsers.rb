# frozen_string_literal: true

module Resolvers
  module Analytics
    module PerPage
      class Browsers < Resolvers::Base
        type Types::Analytics::Browsers, null: false

        argument :page, Integer, required: false, default_value: 0
        argument :size, Integer, required: false, default_value: 10

        def resolve_with_timings(page:, size:)
          results = browsers(page, size)

          {
            items: format_results(results, total_recordings_for_page),
            pagination: {
              page_size: size,
              total: results.total_count
            }
          }
        end

        private

        def total_recordings_for_page
          sql = <<-SQL
            SELECT COUNT(*) total_recordings_count
            FROM recordings
            INNER JOIN pages ON pages.recording_id = recordings.id
            WHERE
              recordings.site_id = ? AND
              to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
              pages.url = ?
          SQL

          variables = [
            object.site.id,
            object.range.from,
            object.range.to,
            object.page
          ]

          Sql.execute(sql, variables).first['total_recordings_count']
        end

        def browsers(page, size) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          Recording
            .joins(:pages)
            .where(
              'recordings.site_id = ? AND
               to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
               pages.url = ?',
              object.site.id,
              object.range.from,
              object.range.to,
              object.page
            )
            .select('DISTINCT(browser) browser, count(*) count')
            .order('count DESC')
            .page(page)
            .per(size)
            .group('browser')
        end

        def format_results(browsers, total_recordings_count)
          browsers.map do |browser|
            {
              browser: browser.browser,
              count: browser.count,
              percentage: Maths.percentage(browser.count.to_f, total_recordings_count)
            }
          end
        end
      end
    end
  end
end
