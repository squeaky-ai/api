# typed: false
# frozen_string_literal: true

require 'async'

# Execute raw sql when the overhead of ActiveRecord
# does not make sense
class Sql
  def self.execute(sql, variables = [])
    query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
    ActiveRecord::Base.connection.exec_query(query)
  end

  class ClickHouse
    def self.execute(sql, variables = [])
      new(sql, variables).execute
    end

    def self.select_all(sql, variables = [])
      new(sql, variables).select_all
    end

    def self.select_value(sql, variables = [])
      new(sql, variables).select_value
    end

    def self.select_one(sql, variables = [])
      new(sql, variables).select_one
    end

    def initialize(sql, variables)
      @sql = sql
      @variables = variables
    end

    def execute
      Async { ::ClickHouse.connection.execute(query) }.wait
    end

    def select_all
      Async { ::ClickHouse.connection.select_all(query) }.wait
    end

    def select_value
      Async { ::ClickHouse.connection.select_value(query) }.wait
    end

    def select_one
      Async { ::ClickHouse.connection.select_one(query) }.wait
    end

    private

    attr_reader :sql, :variables

    def query
      vars = variables.is_a?(Hash) ? [variables] : variables
      ActiveRecord::Base.sanitize_sql_array([sql, *vars])
    end
  end
end
