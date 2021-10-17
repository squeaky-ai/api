# frozen_string_literal: true

module Types
  # The 'recordings' field on the site is handled here as
  #  we only want to load the data if it is requested. The
  # source of truth is in the database, but this is grabbed
  # from elasticsearch
  class RecordingsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 25, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, RecordingSortType, required: false, default_value: 'connected_at__desc', description: 'Sort order')
      field.argument(:filters, RecordingsFiltersType, required: false, default_value: nil, description: 'Filter results')
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
      {
        from: arguments[:page] * arguments[:size],
        size: arguments[:size],
        sort: sort(arguments),
        query: RecordingsQuery.new(site_id, arguments[:query], arguments[:filters].to_h).build
      }
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
      recordings = results['hits']['hits'].map { |r| r['_source'] }
      ids = recordings.map { |r| r['id'] }
      meta = Recording.select('id, viewed, bookmarked').find(ids)

      # The stateful stuff like viewed and bookmarked status is not
      # stored in ElasticSearch and must be fetched from the database
      enrich_items(recordings, meta)
    end

    def enrich_items(recordings, meta)
      recordings.map do |r|
        match = meta.find { |m| m.id == r['id'] }
        r.merge('viewed' => match.viewed, 'bookmarked' => match.bookmarked)
      end
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
