# frozen_string_literal: true

module Resolvers
  module Recordings
    class GetMany < Resolvers::Base
      type Types::Recordings::Recordings, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Recordings::Sort, required: false, default_value: 'connected_at__desc'
      argument :filters, Types::Recordings::Filters, required: false, default_value: nil

      def resolve(page:, size:, sort:, filters:)
        body = {
          from: page * size,
          size: size,
          sort: order(sort),
          query: RecordingsQuery.new(object.id, filters.to_h).build
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

        query = <<-SQL
          SELECT
            recordings.id,
            recordings.viewed,
            recordings.bookmarked,
            visitors.starred
          FROM recordings
          INNER JOIN visitors ON visitors.id = recordings.visitor_id
          WHERE recordings.id IN (?)
        SQL

        meta = Sql.execute(query, [ids])

        # The stateful stuff like viewed and bookmarked status is not
        # stored in ElasticSearch and must be fetched from the database
        enrich_items(recordings, meta)
      end

      def enrich_items(recordings, meta)
        recordings.map do |r|
          match = meta.find { |m| m['id'] == r['id'] }

          unless match
            # Unlike the visitors query this should not happen, we should
            # definitely detele this if they come up
            Rails.logger.error "Recording #{r['id']} does not exist in the database"
            next r
          end

          r['viewed'] = match['viewed']
          r['bookmarked'] = match['bookmarked']
          r['visitor']['starred'] = match['starred']
          r
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
