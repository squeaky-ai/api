# frozen_string_literal: true

class MaterializedViewRefreshJob < ApplicationJob
  queue_as :default

  def perform(model)
    raise StandardError, "#{model} model can't be refrshed" unless model.respond_to?('refresh', true)

    started_at = Time.now
    logger.info "Refreshing #{model} table"

    model.refresh

    duration = (Time.now - started_at).to_i * 60
    logger.info "Done refreshing #{model} table after #{duration} minutes"

    MaterializedViewRefreshJob.set(wait_until: next_run_time).perform_later(model)
  end

  private

  def next_run_time
    # 5am is a good time for US/EU
    Time.now.next_day.beginning_of_day + 5.hours
  end
end
