# frozen_string_literal: true

class Stats
  def self.timer(name, &block)
    start = Time.current
    response = block.call
    duration = Time.current - start

    Rails.logger.info("stats::timer::#{name} - #{duration}")

    response
  end

  def self.count(name)
    Rails.logger.info("stats::count::#{name}")
  end
end
