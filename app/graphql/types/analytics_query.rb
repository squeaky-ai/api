# frozen_string_literal: true

module Types
  # An abstract class to help with analytics extensions
  class AnalyticsQuery < GraphQL::Schema::FieldExtension
    private

    def execute_sql(query, variables)
      # TODO: Is this even right haha? It seems so jank for
      # something I would have thought would be clean in
      # Rails
      sql = ActiveRecord::Base.sanitize_sql_array([query, *variables])
      ActiveRecord::Base.connection.execute(sql).values
    end
  end
end
