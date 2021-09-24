# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  # we only want to load the data if it is requested. The
  # source of truth is in the database, but this is grabbed
  # from elasticsearch
  class RecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, RecordingSortType, required: false, default_value: 'connected_at__asc', description: 'The sort order')
    end

    def resolve(object:, arguments:, **_rest)
      search = search(arguments, object.object.id)
      results = SearchClient.search(index: Recording::INDEX, body: search)

      {
        items: items(results),
        pagination: pagination(arguments, results, arguments[:size])
      }
    end

    private

    def search(arguments, site_id)
      params = {
        from: (arguments[:page] - 1) * arguments[:size],
        size: arguments[:size],
        sort: sort(arguments),
        query: {
          bool: {
            must: [
              { term: { site_id: { value: site_id } } }
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

    def sort(arguments)
      parts = arguments[:sort].split('__')
      sort = {}

      sort[parts.first] = {
        unmapped_type: 'date_nanos',
        order: parts.last
      }

      sort
    end

    def items(results)
      results['hits']['hits'].map { |r| r['_source'] }
    end

    def pagination(arguments, results, size)
      {
        page_size: size,
        total: results['hits']['total']['value'],
        sort: arguments[:sort]
      }
    end
  end
end
