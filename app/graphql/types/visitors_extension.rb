# frozen_string_literal: true

module Types
  # Not really sure this is supposed to work, but I couldn't figure out how to
  # do this the "Ruby" way as I wrote the raw SQL first. But I needed all the
  # helpers that exist in recordings.rb and also the sweet pagination. Hopefully
  # someone in the future can tidy this up.
  class VisitorsExtension < GraphQL::Schema::FieldExtension
    def apply
      field.argument(:page, Integer, required: false, default_value: 0, description: 'The page of results to get')
      field.argument(:size, Integer, required: false, default_value: 15, description: 'The page size')
      field.argument(:query, String, required: false, default_value: '', description: 'The search query')
      field.argument(:sort, VisitorSortType, required: false, default_value: 'last_activity_at__desc', description: 'The sort order')
      field.argument(:filters, VisitorsFiltersType, required: false, default_value: nil, description: 'Filter results')
    end

    def resolve(object:, arguments:, **_rest)
      search = search(arguments, object.object.id)
      results = SearchClient.search(index: Visitor::INDEX, body: search)

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
        sort: sort(arguments, site_id),
        query: VisitorsQuery.new(site_id, arguments[:query], arguments[:filters].to_h).build
      }
    end

    def sort(arguments, site_id)
      parts = arguments[:sort].split('__')
      sort = {}

      if parts.first == 'recordings_count'
        sort = sort_by_recording_count(parts.last, site_id)
      else
        sort[parts.first] = {
          unmapped_type: 'date_nanos',
          order: parts.last
        }
      end

      sort
    end

    def sort_by_recording_count(direction, site_id)
      # Get a list of all the visitor ids in either ascending
      # or descending order based on the amount of recordings
      # they've made
      recordings = Recording
                   .select('visitor_id, COUNT(visitor_id) recordings_count')
                   .where('site_id = ?', site_id)
                   .group('visitor_id')
                   .order("recordings_count #{direction}")

      # Run a custom sort based on the exact order of the ids
      {
        _script: {
          type: 'number',
          script: {
            lang: 'painless',
            params: {
              ids: recordings.map(&:id)
            },
            source: <<-TEXT
              int idsCount = params.ids.size();
              def id = doc['id'].value;
              int foundIdx = params.ids.indexOf(id);
              return foundIdx > -1 ? foundIdx: idsCount + 1;
            TEXT
          }
        }
      }
    end

    def items(results)
      visitors = results['hits']['hits'].map { |r| r['_source'] }
      ids = visitors.map { |r| r['id'] }

      meta = Visitor
             .left_joins(:recordings)
             .select('visitors.id, visitors.starred, COUNT(recordings) count')
             .where('recordings.deleted = false')
             .group('visitors.id')
             .find(ids)

      # The stateful stuff like the starred status is not stored
      # in ElasticSearch and must be fetched from the database
      enrich_items(visitors, meta)
    end

    def enrich_items(visitors, meta)
      visitors.map do |v|
        match = meta.find { |m| m.id == v['id'] }
        v.merge(
          'starred' => match.starred,
          'recordings_count' => { 'total' => match.count, 'new' => 0 },
          # The front end is expecting the attributes as a JSON string
          # because we can't type the unknown
          'attributes' => v['attributes'].to_json
        )
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
