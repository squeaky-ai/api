# frozen_string_literal: true

module Types
  # The list of visitors in a date range
  class AnalyticsPageViewsExtension < GraphQL::Schema::FieldExtension
    def resolve(object:, **_rest)
      site_id = object.object[:site_id]
      from_date = object.object[:from_date]
      to_date = object.object[:to_date]

      search = {
        query: {
          bool: {
            must: [
              {
                term: {
                  site_id: {
                    value: site_id
                  }
                }
              },
              {
                range: {
                  date_time: {
                    gte: from_date,
                    lte: to_date
                  }
                }
              }
            ]
          }
        },
        fields: %w[page_views date_time],
        _source: false
      }

      results = SearchClient.search(index: Recording::INDEX, body: search)

      results['hits']['hits'].map do |hit|
        urls = hit['fields']['page_views'] || []
        {
          total: urls.size,
          unique: urls.tally.values.select { |x| x == 1 }.size,
          timestamp: hit['fields']['date_time'][0]
        }
      end
    end
  end
end
