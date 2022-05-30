# frozen_string_literal: true

class ClickHouseMigration
  def self.read?(site_id)
    [2096].include?(site_id)
  end

  def self.write?(site_id)
    [2096, 82].include?(site_id)
  end
end
