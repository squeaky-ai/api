# frozen_string_literal: true

module Resolvers
  module Analytics
    class Pages < Resolvers::Base
      type Types::Analytics::Pages, null: false

      argument :page, Integer, required: false, default_value: 1
      argument :size, Integer, required: false, default_value: 10

      def resolve(page:, size:)
        total_count = total_pages_count
        results = pages(page, size)
        {
          items: format_results(results, total_count),
          pagination: {
            page_size: size,
            total: total_count['distinct_count']
          }
        }
      end

      private

      def pages(page, size)
        sql = <<-SQL
          SELECT
            exit_rate_1.url url,
            view_times.average_page_duration average_duration,
            exit_rate_2.view_count view_count,
            exit_rate_2.unique_view_count unique_view_count,
            exit_rate_1.exit_count / exit_rate_2.view_count as exit_rate,
            bounce_rate_1.bounce_rate bounce_rate
          FROM
            (
              SELECT
                last_page AS url,
                COUNT(last_page) as exit_count
              FROM
                (
                  SELECT recordings.id,
                    (
                      SELECT pages.url
                      FROM pages
                      WHERE pages.recording_id = recordings.id
                      ORDER BY pages.id DESC
                      LIMIT 1
                    ) AS last_page
                  FROM recordings
                  WHERE
                    site_id = :site_id AND
                    recordings.status IN (:status) AND
                    to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN :start_date AND :end_date
                ) last_page_per_recording
                GROUP BY last_page
                ORDER BY last_page
            ) exit_rate_1
          LEFT JOIN
            (
              SELECT
                pages.url,
                COUNT(pages.recording_id) AS view_count,
                COUNT(distinct pages.recording_id) AS unique_view_count
              FROM pages
              LEFT JOIN recordings ON recordings.id = pages.recording_id
              WHERE
                recordings.site_id = :site_id AND
                recordings.status IN (:status) AND
                to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN :start_date AND :end_date
              GROUP BY pages.url
            ) exit_rate_2 on exit_rate_1.url = exit_rate_2.url
          LEFT JOIN
            (
              SELECT
                first_page as url,
                SUM(CASE WHEN recording_length = 1 THEN 1 ELSE 0 END) / COUNT(first_page) AS bounce_rate
              FROM
                (
                  SELECT recordings.id,
                    (
                      SELECT pages.url
                      FROM pages
                      WHERE pages.recording_id = recordings.id
                      ORDER BY pages.id LIMIT 1
                    ) AS first_page,
                    (
                      SELECT COUNT(pages.recording_id)
                      FROM pages
                      WHERE pages.recording_id = recordings.id
                      GROUP BY pages.recording_id
                      LIMIT 1
                    ) AS recording_length
                  FROM recordings
                  WHERE site_id = :site_id
                ) first_page_and_length
              GROUP BY first_page
              ORDER BY first_page
            ) bounce_rate_1 on exit_rate_1.url = bounce_rate_1.url
          LEFT JOIN
            (
              SELECT
                pages.url,
                avg(pages.exited_at - pages.entered_at) AS average_page_duration
              FROM pages
              LEFT JOIN recordings ON recordings.id = pages.recording_id
              WHERE
                to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN :start_date AND :end_date AND
                recordings.status IN (:status) AND
                recordings.site_id = :site_id
              GROUP BY pages.url
            ) view_times ON exit_rate_1.url = view_times.url
          ORDER BY view_count DESC
          LIMIT :limit
          OFFSET :offset;
        SQL

        Sql.execute(
          sql,
          [
            {
              site_id: object[:site_id],
              start_date: object[:from_date],
              end_date: object[:to_date],
              status: [Recording::ACTIVE, Recording::DELETED],
              limit: size,
              offset: (page - 1) * size
            }
          ]
        )
      end

      def format_results(pages, total_count)
        pages.map do |page|
          {
            url: page['url'],
            view_count: page['view_count'],
            view_percentage: percentage(page['view_count'], total_count['all_count']),
            unique_view_count: page['unique_view_count'],
            unique_view_percentage: percentage(page['unique_view_count'], total_count['all_count']),
            exit_rate_percentage: page['exit_rate'] * 100,
            bounce_rate_percentage: page['bounce_rate'].to_i * 100,
            average_duration: page['average_duration']
          }
        end
      end

      def total_pages_count
        sql = <<-SQL
          SELECT
            COUNT(pages.url) all_count,
            COUNT(DISTINCT(pages.url)) distinct_count
          FROM recordings
          INNER JOIN pages ON pages.recording_id = recordings.id
          WHERE
            recordings.site_id = ? AND
            to_timestamp(recordings.disconnected_at / 1000)::date BETWEEN ? AND ? AND
            recordings.status IN (?)
        SQL

        variables = [
          object[:site_id],
          object[:from_date],
          object[:to_date],
          [Recording::ACTIVE, Recording::DELETED]
        ]

        Sql.execute(sql, variables).first
      end

      def percentage(count, total)
        ((count.to_f / total) * 100).round(2)
      end
    end
  end
end
