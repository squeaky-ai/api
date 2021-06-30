# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  # we only want to load the data if it is requested. The
  # gateway is responsible for populating this and it is
  # stored in Dynamo
  class RecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, SortType, required: false, default_value: 'DESC', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      search = search(arguments, object.object.uuid)
      results = SearchClient.search(index: Recording::INDEX, body: search)

      {
        items: items(results),
        pagination: pagination(arguments, results, arguments[:size])
      }
    end

    private

    def search(arguments, uuid)
      params = {
        from: arguments[:page] * arguments[:size],
        size: arguments[:size],
        sort: {
          timestamp: {
            unmapped_type: 'date_nanos',
            order: arguments[:sort].downcase
          }
        },
        query: {
          bool: {
            must: [
              { term: { 'site_id.keyword': uuid } }
            ]
          }
        }
      }

      unless arguments[:query].empty?
        params[:query][:bool][:filter] = [
          { query_string: { query: "*#{arguments[:query]}*" } }
        ]
      end

      params
    end

    def items(results)
      results['hits']['hits'].map { |r| r['_source'] }
    end

    def pagination(arguments, results, size)
      {
        page_size: size,
        page_count: (results['hits']['total']['value'].to_f / size).ceil,
        sort: arguments[:sort]
      }
    end
  end
end
