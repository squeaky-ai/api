# frozen_string_literal: true

class WeeklyReviewEmailsJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*_args)
    from_date, to_date = date_range

    suitable_sites(from_date, to_date).each do |site_id|
      review = WeeklyReviewService::Generator.new(site_id:, from_date:, to_date:)

      review.members.each do |member|
        SiteMailer.weekly_review(review.site, review.to_h, member.user).deliver_later
      end
    rescue StandardError => e
      logger.error "Failed to build weekly review - #{e}"
    end
  end

  private

  def date_range
    now = Time.zone.today
    now -= 1.week

    [now.beginning_of_week.to_date, now.end_of_week.to_date]
  end

  def suitable_sites(from_date, to_date)
    sql = <<-SQL.squish
      SELECT
        DISTINCT(site_id)
      FROM
        recordings
      WHERE
        toDate(disconnected_at / 1000)::date BETWEEN :from_date AND :to_date
    SQL

    variables = {
      from_date:,
      to_date:
    }

    Sql::ClickHouse.select_all(sql, variables).pluck('site_id')
  end
end
