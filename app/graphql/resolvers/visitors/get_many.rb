# frozen_string_literal: true

module Resolvers
  module Visitors
    class GetMany < Resolvers::Base
      type Types::Visitors::Visitors, null: false

      argument :page, Integer, required: false, default_value: 0
      argument :size, Integer, required: false, default_value: 25
      argument :sort, Types::Visitors::Sort, required: false, default_value: 'last_activity_at__desc'
      argument :filters, Types::Visitors::Filters, required: false, default_value: nil

      def resolve(page:, size:, sort:, filters:)
        body = {
          from: page * size,
          size: size,
          sort: order(sort),
          query: VisitorsQuery.new(object.id, filters.to_h).build
        }

        results = SearchClient.search(index: Visitor::INDEX, body: body)

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
        visitors = results['hits']['hits'].map { |r| r['_source'] }
        ids = visitors.map { |r| r['id'] }

        meta = Visitor
               .left_joins(:recordings)
               .select(
                 'visitors.id,
                  visitors.starred,
                  COUNT(recordings) count,
                  COUNT(CASE recordings.viewed WHEN TRUE THEN 1 ELSE NULL END) recordings_viewed'
               )
               .where('recordings.deleted = false')
               .group('visitors.id')
               .where(id: ids)

        # The stateful stuff like the starred status is not stored
        # in ElasticSearch and must be fetched from the database
        enrich_items(visitors, meta)
      end

      def enrich_items(visitors, meta)
        visitors.map do |v|
          match = meta.find { |m| m.id == v['id'] }
          v.merge(
            'starred' => match&.starred || false,
            'recordings_count' => { 'total' => match&.count || 0, 'new' => 0 },
            'viewed' => match.recordings_viewed&.positive?,
            # The front end is expecting the attributes as a JSON string
            # because we can't type the unknown
            'attributes' => v['attributes'].to_json
          )
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
