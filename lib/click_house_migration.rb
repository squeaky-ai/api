# frozen_string_literal: true

class ClickHouseMigration
  def self.read?(site_id)
    return true unless Rails.env.production?

    [82, 2096].include?(site_id)
  end
end
