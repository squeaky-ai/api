# frozen_string_literal: true

class WeeklyReviewEmailsJob < ApplicationJob
  queue_as :default

  sidekiq_options retry: false

  def perform(*args) # rubocop:disable Metrics/AbcSize
    from_date, to_date = date_range(args)
    site_ids = suitable_sites(from_date, to_date)

    logger.info "Generating weekly review emails for #{site_ids.join(',')} between #{from_date} and #{to_date}"

    site_ids.each do |site_id|
      review = WeeklyReview.new(site_id, from_date, to_date)

      review.members.each do |member|
        SiteMailer.weekly_review(review.site, review.to_h, member.user).deliver_later
      end
    rescue StandardError => e
      logger.error e
    end
  end

  private

  def date_range(args)
    # The job could fail and we might want to rerun
    # a job for a given time period
    return [args.first[:from_date], args.first[:to_date]] unless args.empty?

    now = Date.today
    now -= 1.week

    [now.beginning_of_week, now.end_of_week]
  end

  def suitable_sites(from_date, to_date)
    sql = <<-SQL
      SELECT site_id
      FROM (
        SELECT sites.id site_id, count(recordings) recordings_count
        FROM sites
        INNER JOIN recordings on recordings.site_id = sites.id
        WHERE to_timestamp(disconnected_at / 1000)::date BETWEEN ? AND ?
        GROUP BY sites.id
      ) c
      WHERE recordings_count > 0;
    SQL

    Sql.execute(sql, [from_date, to_date]).map { |x| x['site_id'] }
  end
end
