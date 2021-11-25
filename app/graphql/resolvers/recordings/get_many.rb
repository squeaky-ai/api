# frozen_string_literal: true

module Resolvers
  module Recordings
    class GetMany < Resolvers::Base
      type Types::Recordings::Recordings, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :query, String, required: false, default_value: ''
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'
      argument :filters, Types::Recordings::Filters, required: false, default_value: nil

      def resolve(page:, size:, query:, sort:, filters:)
        body = {
          from: page * size,
          size: size,
          sort: order(sort),
          query: RecordingsQuery.new(object.id, query, filters.to_h).build
        }

        results = SearchClient.search(index: Recording::INDEX, body: body)

        {
          items: items(results),
          pagination: pagination(size, sort, results)
        }
      end

      private

      def order(sort)
        parts = sort.split('__')
        order = {}

        order[parts.first] = {
          unmapped_type: 'date_nanos',
          order: parts.last
        }

        order
      end

      def items(results)
        recordings = results['hits']['hits'].map { |r| r['_source'] }
        ids = recordings.map { |r| r['id'] }
        meta = Recording.select('id, viewed, bookmarked').where(id: ids)

        # The stateful stuff like viewed and bookmarked status is not
        # stored in ElasticSearch and must be fetched from the database
        enrich_items(recordings, meta)
      end

      def enrich_items(recordings, meta)
        recordings.map do |r|
          match = meta.find { |m| m.id == r['id'] }
          r.merge('viewed' => match&.viewed || false, 'bookmarked' => match&.bookmarked || false)
        end
      end

      def pagination(size, sort, results)
        {
          page_size: size,
          total: results['hits']['total']['value'],
          sort: sort
        }
      end
    end
  end
end
