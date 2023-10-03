# frozen_string_literal: true

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
      ::ClickHouse.connection.execute(query)
    end

    def select_all
      ::ClickHouse.connection.select_all(query)
    end

    def select_value
      ::ClickHouse.connection.select_value(query)
    end

    def select_one
      ::ClickHouse.connection.select_one(query)
    end

    private

    attr_reader :sql, :variables

    def query
      vars = variables.is_a?(Hash) ? [variables] : variables
      ActiveRecord::Base.sanitize_sql_array([sql, *vars])
    end
  end
end
