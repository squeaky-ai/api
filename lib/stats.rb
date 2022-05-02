# frozen_string_literal: true

class Stats
  def self.timer(name, &block)
    start = Time.now
    response = block.call
    duration = Time.now - start

    Rails.logger.info("stats::timer::#{name} - #{duration}")

    response
  end

  def self.count(name)
    Rails.logger.info("stats::count::#{name}")
  end
end
