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
      query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
      ::ClickHouse.connection.execute(query)
    end

    def self.select_all(sql, variables = [])
      query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
      ::ClickHouse.connection.select_all(query)
    end

    def self.select_value(sql, variables = [])
      query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
      ::ClickHouse.connection.select_value(query)
    end
  end
end
