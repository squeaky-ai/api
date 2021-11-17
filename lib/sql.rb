# frozen_string_literal: true

# Execute raw sql
class Sql
  def self.execute(sql, variables)
    query = ActiveRecord::Base.sanitize_sql_array([sql, *variables])
    ActiveRecord::Base.connection.exec_query(query)
  end
end